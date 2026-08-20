import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from psych_lsp import PsychLanguageServer


class TestAssistantFeatures(unittest.TestCase):
    def test_project_summary_and_symbol_explanation(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "script.lua").write_text("function onCreate()\nend\n", encoding="utf-8")
            Image.new("RGBA", (32, 32), (255, 0, 0, 255)).save(root / "icon.png")

            server = PsychLanguageServer()
            server.initialize({"rootUri": root.as_uri()})
            summary = server.handle_request("psychIde/projectSummary", {"folderPath": str(root)})
            guide = server.handle_request("psychIde/explainSymbol", {"name": "makeLuaSprite"})

            self.assertTrue(summary["ok"])
            self.assertEqual(summary["files"]["lua"], 1)
            self.assertEqual(summary["files"]["png"], 1)
            self.assertTrue(guide["ok"])
            self.assertIn("beginner", guide)
            self.assertIn("example", guide)


if __name__ == "__main__":
    unittest.main()
