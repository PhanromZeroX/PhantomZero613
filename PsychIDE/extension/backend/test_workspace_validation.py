import sys
import tempfile
import unittest
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from psych_lsp import PsychLanguageServer


class TestWorkspaceValidation(unittest.TestCase):
    def test_validates_all_workspace_lua_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            (root / "good.lua").write_text("function onCreate()\n    debugPrint('ok')\nend\n", encoding="utf-8")
            (root / "bad.lua").write_text("function onCreate()\n    makeLuaSprite('only-one')\nend\n", encoding="utf-8")

            server = PsychLanguageServer()
            server.initialize({"rootUri": root.as_uri()})
            result = server.handle_request("psychIde/validateWorkspace", {})

            self.assertTrue(result["ok"])
            self.assertEqual(result["totals"]["files"], 2)
            self.assertGreaterEqual(result["totals"]["errors"], 1)
            self.assertEqual(len(result["results"]), 1)
            self.assertTrue(result["results"][0]["uri"].endswith("bad.lua"))


if __name__ == "__main__":
    unittest.main()
