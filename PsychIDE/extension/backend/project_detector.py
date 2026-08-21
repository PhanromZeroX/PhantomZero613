"""Detect Psych Engine project roots from common engine and mod markers."""

from pathlib import Path
from typing import Any, Dict, List


MARKERS = {
    "psych_engine": ["Project.xml", "source", "assets"],
    "psych_mod": ["mods"],
}


def detect_project(folder_path: str) -> Dict[str, Any]:
    root = Path(folder_path).resolve()
    if not root.is_dir():
        return {"ok": False, "error": f"Folder not found: {folder_path}"}

    present = []
    for marker in sorted({marker for markers in MARKERS.values() for marker in markers}):
        if (root / marker).exists():
            present.append(marker)

    has_engine = all((root / marker).exists() for marker in MARKERS["psych_engine"])
    has_mod = (root / "mods").is_dir() or (root / "assets").is_dir()
    if has_engine:
        kind = "Psych Engine source"
        confidence = "high"
    elif has_mod:
        kind = "Psych Engine mod"
        confidence = "medium"
    else:
        kind = "Unknown"
        confidence = "low"

    return {
        "ok": True,
        "root": str(root),
        "kind": kind,
        "confidence": confidence,
        "markers": present,
        "isPsychEngine": has_engine or has_mod,
    }
