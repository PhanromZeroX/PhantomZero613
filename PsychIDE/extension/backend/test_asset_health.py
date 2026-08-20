import json
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from asset_health import scan_asset_folder
from psych_lsp import PsychLanguageServer


class TestAssetHealth(unittest.TestCase):
    def test_scan_reports_oversized_and_missing_metadata_assets(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            nested = root / "characters"
            nested.mkdir()
            Image.new("RGBA", (3000, 100), (255, 0, 0, 255)).save(nested / "hero.png")
            Image.new("RGBA", (64, 64), (0, 255, 0, 255)).save(root / "icon.png")

            result = scan_asset_folder(str(root), profile="low-end")

            self.assertTrue(result["ok"])
            self.assertEqual(result["totals"]["files"], 2)
            self.assertEqual(result["totals"]["oversized"], 1)
            self.assertEqual(result["totals"]["missingMetadata"], 2)
            hero = next(asset for asset in result["assets"] if asset["path"] == "characters/hero.png")
            self.assertIn("oversized", hero["issues"])

    def test_scan_validates_xml_and_json_sidecars(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            image_path = root / "sheet.png"
            Image.new("RGBA", (128, 64), (0, 0, 255, 255)).save(image_path)
            ET.ElementTree(ET.Element("TextureAtlas")).write(root / "sheet.xml", encoding="utf-8")
            (root / "sheet-data.json").write_text(json.dumps({"frames": []}), encoding="utf-8")
            (root / "sheet-bad.json").write_text("{bad", encoding="utf-8")

            result = scan_asset_folder(str(root), profile="standard")

            self.assertEqual(result["totals"]["files"], 1)
            self.assertEqual(result["totals"]["missingMetadata"], 0)
            self.assertEqual(result["totals"]["invalidMetadata"], 1)
            self.assertIn("invalid-metadata", result["assets"][0]["issues"])

    def test_language_server_exposes_asset_health_scan(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            Image.new("RGBA", (64, 64), (255, 255, 255, 255)).save(root / "icon.png")

            server = PsychLanguageServer()
            result = server.handle_request("psychIde/scanAssetHealth", {
                "folderPath": str(root),
                "profile": "balanced",
            })

            self.assertTrue(result["ok"])
            self.assertEqual(result["totals"]["files"], 1)


if __name__ == "__main__":
    unittest.main()
