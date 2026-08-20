"""Load EmmyLua API annotations from a Psych Engine globals stub."""

from pathlib import Path
import re
from typing import Any, Dict, List


_FUNCTION_PATTERN = re.compile(r"^\s*function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)")
_PARAM_PATTERN = re.compile(r"^\s*---@param\s+([A-Za-z_][A-Za-z0-9_]*)\s+([^\s]+)")
_RETURN_PATTERN = re.compile(r"^\s*---@return\s+([^\s]+)")


class LuaApiLoader:
    def load_workspace_api(self, workspace_root: Path) -> Dict[str, List[Dict[str, Any]]]:
        for candidate in (
            workspace_root / "PsychEngine_Globals.lua",
            workspace_root / "docs" / "psych_engine_globals.lua",
        ):
            if candidate.is_file():
                return self._parse(candidate)
        return {"functions": [], "callbacks": []}

    def _parse(self, path: Path) -> Dict[str, List[Dict[str, Any]]]:
        functions: List[Dict[str, Any]] = []
        callbacks: List[Dict[str, Any]] = []
        pending_params: List[Dict[str, str]] = []
        pending_return = "void"

        for line in path.read_text(encoding="utf-8").splitlines():
            param = _PARAM_PATTERN.match(line)
            if param:
                pending_params.append({"name": param.group(1), "type": param.group(2)})
                continue
            returned = _RETURN_PATTERN.match(line)
            if returned:
                pending_return = returned.group(1)
                continue
            function = _FUNCTION_PATTERN.match(line)
            if not function:
                if line.strip() and not line.strip().startswith("---"):
                    pending_params = []
                    pending_return = "void"
                continue

            name, raw_args = function.groups()
            declared_args = [arg.strip() for arg in raw_args.split(",") if arg.strip()]
            params = pending_params or [{"name": arg, "type": "any"} for arg in declared_args]
            spec = {
                "name": name,
                "args": params,
                "return": pending_return,
                "description": "Psych Engine v1.0.4 API stub",
            }
            (callbacks if name.startswith("on") or name.endswith("Hit") else functions).append(spec)
            pending_params = []
            pending_return = "void"

        return {"functions": functions, "callbacks": callbacks}
