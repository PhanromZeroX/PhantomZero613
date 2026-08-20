"""Read-only health checks for Psych Engine asset folders."""

from __future__ import annotations

import json
import os
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any, Dict, List, Optional

from PIL import Image


PROFILE_LIMITS = {
    "low-end": 2048,
    "balanced": 4096,
    "standard": 8192,
    "high-end": 16384,
}


def _image_metadata(image_path: Path) -> Dict[str, Any]:
    try:
        with Image.open(image_path) as image:
            width, height = image.size
            return {
                "width": width,
                "height": height,
                "format": image.format,
                "mode": image.mode,
                "megapixels": round((width * height) / 1_000_000, 3),
                "fileBytes": image_path.stat().st_size,
            }
    except Exception as exc:
        return {"error": str(exc), "fileBytes": image_path.stat().st_size}


def _metadata_paths(image_path: Path) -> List[Path]:
    stem = image_path.stem
    return [
        candidate
        for candidate in image_path.parent.iterdir()
        if candidate.is_file()
        and candidate.suffix.lower() in {".xml", ".json"}
        and candidate.stem.startswith(stem)
    ]


def _validate_metadata(metadata_path: Path) -> Optional[str]:
    try:
        if metadata_path.suffix.lower() == ".xml":
            ET.parse(metadata_path)
        else:
            with metadata_path.open("r", encoding="utf-8") as handle:
                json.load(handle)
    except Exception as exc:
        return str(exc)
    return None


def scan_asset_folder(
    folder_path: str,
    profile: str = "balanced",
    max_dimension: Optional[int] = None,
) -> Dict[str, Any]:
    """Scan PNG assets recursively without changing any files."""
    root = Path(folder_path).resolve()
    if not root.is_dir():
        return {"ok": False, "error": f"Folder not found: {folder_path}"}

    limit = max_dimension or PROFILE_LIMITS.get(profile, PROFILE_LIMITS["balanced"])
    assets: List[Dict[str, Any]] = []
    totals = {"files": 0, "bytes": 0, "oversized": 0, "missingMetadata": 0, "invalidMetadata": 0}

    for image_path in sorted(root.rglob("*.png")):
        if "psychide-resized" in image_path.parts:
            continue

        relative_path = image_path.relative_to(root).as_posix()
        metadata = _image_metadata(image_path)
        sidecars = _metadata_paths(image_path)
        metadata_errors = []
        for sidecar in sidecars:
            error = _validate_metadata(sidecar)
            if error:
                metadata_errors.append({"path": sidecar.relative_to(root).as_posix(), "error": error})

        issues: List[str] = []
        recommendations: List[str] = []
        width = metadata.get("width", 0)
        height = metadata.get("height", 0)
        if metadata.get("error"):
            issues.append("unreadable-image")
        if max(width, height) > limit:
            issues.append("oversized")
            recommendations.append(f"Export a {profile} copy at {limit}px or below")
        if not sidecars:
            issues.append("missing-metadata")
            recommendations.append("Add matching XML or JSON frame metadata if this is an animated sheet")
        if metadata_errors:
            issues.append("invalid-metadata")
            recommendations.append("Fix invalid sidecar metadata before loading the asset")
        if metadata.get("fileBytes", 0) > 4 * 1024 * 1024:
            recommendations.append("Consider a smaller export or PNG optimization for lower-memory devices")

        totals["files"] += 1
        totals["bytes"] += metadata.get("fileBytes", 0)
        totals["oversized"] += int("oversized" in issues)
        totals["missingMetadata"] += int("missing-metadata" in issues)
        totals["invalidMetadata"] += int("invalid-metadata" in issues)
        assets.append({
            "path": relative_path,
            "metadata": metadata,
            "sidecars": [path.relative_to(root).as_posix() for path in sidecars],
            "metadataErrors": metadata_errors,
            "issues": issues,
            "recommendations": recommendations,
        })

    return {
        "ok": True,
        "folder": str(root),
        "profile": profile,
        "maxDimension": limit,
        "totals": totals,
        "assets": assets,
    }
