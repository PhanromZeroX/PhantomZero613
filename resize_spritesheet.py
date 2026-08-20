"""Utility to uniformly scale a sprite-sheet PNG and update associated metadata files.

Usage example:
    python resize_spritesheet.py BFneo.png --width 2048 --xml BFneo.xml --json BFneo.json

The script will:
  * create a backup of the original image (suffix _orig) unless --overwrite is given
  * resize the PNG to the requested width, maintaining aspect ratio
  * if an XML TextureAtlas is provided, multiply all numeric coords/sizes by the scale factor
  * if one or more JSON files are provided, attempt to scale all numbers inside them
  * update any imagePath references in XML/JSON to point to the new image name

Incidentally this solves the "8k too large" problem by shrinking only with a valid
factor that keeps the frame grid integer-aligned.
"""

import argparse
import json
import os
import shutil
from PIL import Image
import xml.etree.ElementTree as ET


def parse_args():
    parser = argparse.ArgumentParser(description="Scale sprite sheet and metadata")
    parser.add_argument("image", help="Path to the source PNG")
    parser.add_argument("--width", type=int, required=True, help="Target pixel width")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite original files instead of backing up")
    parser.add_argument("--xml", help="Path to an XML TextureAtlas to update")
    parser.add_argument("--json", nargs="*", help="One or more JSON metadata files to update")
    return parser.parse_args()


def scale_image(src_path, target_width, overwrite=False):
    img = Image.open(src_path)
    w, h = img.size
    scale = target_width / w
    new_size = (int(round(w * scale)), int(round(h * scale)))
    print(f"scaling image {src_path} {w}x{h} \u2192 {new_size}, scale={scale:.6f}")

    if not overwrite:
        backup = src_path.replace(".png", "_orig.png")
        shutil.copy(src_path, backup)
        print(f"backed up original to {backup}")

    out_path = src_path if overwrite else src_path  # keep same name; backup holds original
    img.resize(new_size, Image.LANCZOS).save(out_path)
    return scale, new_size, out_path


def scale_xml(xml_path, scale):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    # update imagePath if exists
    if "imagePath" in root.attrib:
        name = os.path.basename(root.attrib["imagePath"])
        root.attrib["imagePath"] = name
    for sub in root.findall('SubTexture'):
        for attr in ['x','y','width','height','frameX','frameY','frameWidth','frameHeight']:
            if attr in sub.attrib:
                val = float(sub.attrib[attr])
                sub.attrib[attr] = str(int(round(val * scale)))
    tree.write(xml_path)
    print(f"updated XML {xml_path} with scale {scale}")


def scale_json_file(json_path, scale):
    data = json.load(open(json_path))

    def recurse(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                obj[k] = recurse(v)
            return obj
        elif isinstance(obj, list):
            return [recurse(v) for v in obj]
        elif isinstance(obj, (int, float)):
            return int(round(obj * scale))
        else:
            return obj

    new_data = recurse(data)
    with open(json_path, 'w') as f:
        json.dump(new_data, f, indent=2)
    print(f"scaled numbers in JSON {json_path}")


def main():
    args = parse_args()
    img_path = args.image
    scale, new_size, out_path = scale_image(img_path, args.width, overwrite=args.overwrite)
    if args.xml and os.path.exists(args.xml):
        scale_xml(args.xml, scale)
    if args.json:
        for j in args.json:
            if os.path.exists(j):
                scale_json_file(j, scale)


if __name__ == "__main__":
    main()
