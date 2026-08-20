"""Deterministic project-level rules for Psych Engine Lua scripts."""

from pathlib import Path
import re
from typing import Dict, List, Optional, Tuple


_CALLBACK_PATTERN = re.compile(r"\bfunction\s+(on[A-Z][A-Za-z0-9_]*)\s*\(")
_SHADER_PATTERN = re.compile(r"\binitLuaShader\s*\(\s*['\"]([^'\"]+)['\"]")
_IMAGE_PATTERN = re.compile(
    r"\b(?:makeLuaSprite|makeAnimatedLuaSprite)\s*\(\s*['\"][^'\"]+['\"]\s*,\s*['\"]([^'\"]+)['\"]"
)
_SOUND_PATTERN = re.compile(
    r"\b(?:playSound|precacheSound|playMusic|precacheMusic)\s*\(\s*['\"]([^'\"]+)['\"]"
)


class ProjectRules:
    def __init__(self, workspace_root: Optional[Path] = None) -> None:
        self.workspace_root = workspace_root

    def set_workspace(self, workspace_root: Optional[Path]) -> None:
        self.workspace_root = workspace_root

    def validate(self, uri: str, text: str) -> Tuple[List[Dict], List[Dict]]:
        errors: List[Dict] = []
        warnings: List[Dict] = []
        callbacks: Dict[str, int] = {}

        for line_no, line in enumerate(text.splitlines(), 1):
            callback = _CALLBACK_PATTERN.search(line)
            if callback:
                name = callback.group(1)
                if name in callbacks:
                    errors.append({
                        "line": line_no,
                        "col": callback.start(1),
                        "length": len(name),
                        "code": "psych-duplicate-callback",
                        "message": f"Duplicate lifecycle callback: {name}. Merge the callback bodies.",
                    })
                else:
                    callbacks[name] = line_no

            shader = _SHADER_PATTERN.search(line)
            if shader and self.workspace_root and not self._shader_exists(shader.group(1)):
                warnings.append({
                    "line": line_no,
                    "col": shader.start(1),
                    "length": len(shader.group(1)),
                    "code": "psych-missing-shader",
                    "message": f"Shader asset not found in the project: {shader.group(1)}",
                })

            image = _IMAGE_PATTERN.search(line)
            if image and image.group(1) and self.workspace_root and not self._asset_exists(image.group(1), "images"):
                warnings.append({
                    "line": line_no,
                    "col": image.start(1),
                    "length": len(image.group(1)),
                    "code": "psych-missing-image",
                    "message": f"Image asset not found in the project: {image.group(1)}",
                })

            sound = _SOUND_PATTERN.search(line)
            if sound and sound.group(1) and self.workspace_root and not self._asset_exists(sound.group(1), "sounds", "music"):
                warnings.append({
                    "line": line_no,
                    "col": sound.start(1),
                    "length": len(sound.group(1)),
                    "code": "psych-missing-audio",
                    "message": f"Audio asset not found in the project: {sound.group(1)}",
                })

        return errors, warnings

    def _shader_exists(self, shader_name: str) -> bool:
        if not self.workspace_root or not self.workspace_root.exists():
            return True
        if Path(shader_name).suffix:
            candidates = [self.workspace_root / shader_name]
        else:
            candidates = [
                self.workspace_root / "shaders" / f"{shader_name}.frag",
                self.workspace_root / "shaders" / f"{shader_name}.vsh",
            ]
            candidates.extend(self.workspace_root.rglob(f"{shader_name}.frag"))
            candidates.extend(self.workspace_root.rglob(f"{shader_name}.vsh"))
        return any(candidate.is_file() for candidate in candidates)

    def _asset_exists(self, asset_name: str, *folders: str) -> bool:
        if not self.workspace_root or not self.workspace_root.exists():
            return True
        suffixes = ("", ".png", ".jpg", ".jpeg", ".webp", ".ogg", ".wav", ".mp3")
        candidates = []
        for folder in folders:
            for suffix in suffixes:
                candidates.append(self.workspace_root / folder / f"{asset_name}{suffix}")
        for candidate in candidates:
            if candidate.is_file():
                return True
        return any(
            candidate.is_file() and candidate.stem == Path(asset_name).name
            for folder in folders
            for candidate in self.workspace_root.rglob(f"{Path(asset_name).name}.*")
        )
