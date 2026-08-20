"""Utility to resize sprite-sheet PNGs and update associated metadata.

This is a Psych Engine-friendly asset tool that keeps source-frame alignment and
updates related XML/JSON metadata after a resize operation.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
from typing import Any, Dict, List, Optional

from PIL import Image
import xml.etree.ElementTree as ET


def _scale_value(value: Any, scale: float) -> Any:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return int(round(float(value) * scale))
    return value


def _scale_json_object(obj: Any, scale: float) -> Any:
    if isinstance(obj, dict):
        return {k: _scale_json_object(v, scale) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_scale_json_object(v, scale) for v in obj]
    if isinstance(obj, (int, float)) and not isinstance(obj, bool):
        return int(round(float(obj) * scale))
    return obj


def scale_image(src_path: str, target_width: int, overwrite: bool = False) -> Dict[str, Any]:
    img = Image.open(src_path)
    width, height = img.size
    if target_width <= 0:
        raise ValueError("Target width must be greater than zero.")
    if width <= 0 or height <= 0:
        raise ValueError(f"Image dimensions are invalid for {src_path}: {width}x{height}")

    scale = target_width / width
    new_size = (int(round(width * scale)), int(round(height * scale)))

    if not overwrite:
        backup = src_path.replace(".png", "_orig.png")
        if not os.path.exists(backup):
            shutil.copy(src_path, backup)
        original_path = backup
    else:
        original_path = src_path

    img.resize(new_size, Image.LANCZOS).save(src_path)
    return {
        "ok": True,
        "original_size": [width, height],
        "new_size": [new_size[0], new_size[1]],
        "scale": float(scale),
        "image_path": src_path,
        "backup_path": original_path if not overwrite else None,
    }


def scale_xml(xml_path: str, scale: float, image_name: Optional[str] = None) -> Dict[str, Any]:
    if not os.path.exists(xml_path):
        return {"ok": True, "updated": False, "xml_path": xml_path, "reason": "missing"}

    tree = ET.parse(xml_path)
    root = tree.getroot()

    if "imagePath" in root.attrib:
        root.attrib["imagePath"] = image_name or os.path.basename(root.attrib["imagePath"]) or root.attrib["imagePath"]

    for sub in root.findall('SubTexture'):
        for attr in ['x', 'y', 'width', 'height', 'frameX', 'frameY', 'frameWidth', 'frameHeight']:
            if attr in sub.attrib:
                try:
                    sub.attrib[attr] = str(int(round(float(sub.attrib[attr]) * scale)))
                except ValueError:
                    pass

    tree.write(xml_path, encoding='utf-8', xml_declaration=True)
    return {"ok": True, "updated": True, "xml_path": xml_path, "scale": float(scale)}


def scale_json_file(json_path: str, scale: float) -> Dict[str, Any]:
    if not os.path.exists(json_path):
        return {"ok": True, "updated": False, "json_path": json_path, "reason": "missing"}

    with open(json_path, 'r', encoding='utf-8') as handle:
        data = json.load(handle)

    updated = _scale_json_object(data, scale)

    with open(json_path, 'w', encoding='utf-8') as handle:
        json.dump(updated, handle, indent=2)

    return {"ok": True, "updated": True, "json_path": json_path, "scale": float(scale)}


def resize_sprite_sheet(
    image_path: str,
    target_width: int,
    xml_path: Optional[str] = None,
    json_paths: Optional[List[str]] = None,
    overwrite: bool = False,
    output_image_path: Optional[str] = None,
    output_xml_path: Optional[str] = None,
    output_json_paths: Optional[List[str]] = None,
) -> Dict[str, Any]:
    """Resize a sprite sheet and update any related metadata files."""
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Image not found: {image_path}")

    if output_image_path:
        os.makedirs(os.path.dirname(output_image_path), exist_ok=True)
        shutil.copy2(image_path, output_image_path)
        image_result = scale_image(output_image_path, target_width, overwrite=True)
        image_result["source_image_path"] = image_path
    else:
        image_result = scale_image(image_path, target_width, overwrite=overwrite)

    scale = image_result["scale"]

    metadata_xml_path = output_xml_path or xml_path
    if output_xml_path and xml_path and os.path.exists(xml_path):
        os.makedirs(os.path.dirname(output_xml_path), exist_ok=True)
        shutil.copy2(xml_path, output_xml_path)
    xml_result = scale_xml(
        metadata_xml_path,
        scale,
        image_name=os.path.basename(image_result.get("image_path", image_path)),
    ) if metadata_xml_path else {
        "ok": True,
        "updated": False,
        "xml_path": metadata_xml_path,
    }

    json_results = []
    source_json_paths = json_paths or []
    destination_json_paths = output_json_paths or source_json_paths
    for index, json_path in enumerate(source_json_paths):
        destination = destination_json_paths[index] if index < len(destination_json_paths) else json_path
        if output_json_paths and os.path.exists(json_path):
            os.makedirs(os.path.dirname(destination), exist_ok=True)
            shutil.copy2(json_path, destination)
        json_results.append(scale_json_file(destination, scale))

    return {
        "ok": True,
        "image_path": image_result.get("image_path", image_path),
        "source_image_path": image_path,
        "original_size": image_result["original_size"],
        "new_size": image_result["new_size"],
        "scale": float(scale),
        "backup_path": image_result.get("backup_path"),
        "xml": xml_result,
        "json": json_results,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scale sprite sheet and metadata")
    parser.add_argument("image", help="Path to the source PNG")
    parser.add_argument("--width", type=int, required=True, help="Target pixel width")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite original files instead of backing up")
    parser.add_argument("--xml", help="Path to an XML TextureAtlas to update")
    parser.add_argument("--json", nargs="*", help="One or more JSON metadata files to update")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    result = resize_sprite_sheet(
        args.image,
        target_width=args.width,
        xml_path=args.xml,
        json_paths=args.json or [],
        overwrite=args.overwrite,
    )
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
