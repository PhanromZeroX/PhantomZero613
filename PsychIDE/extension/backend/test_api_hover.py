import sys
import unittest
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from psych_lsp import PsychLanguageServer


class TestApiHover(unittest.TestCase):
    def test_function_hover_includes_beginner_guide_example_and_tips(self):
        server = PsychLanguageServer()
        uri = "file:///tmp/hover.lua"
        server.did_open({
            "textDocument": {
                "uri": uri,
                "text": "function onCreate()\n    makeLuaSprite('logo', 'logo', 0, 0)\nend\n",
            }
        })

        hover = server.hover({
            "textDocument": {"uri": uri},
            "position": {"line": 1, "character": 8},
        })
        value = hover["contents"]["value"]
        self.assertIn("Beginner guide", value)
        self.assertIn("makeLuaSprite('logo', 'logo', 100, 50)", value)
        self.assertIn("Tags are names", value)

    def test_callback_hover_includes_callback_guidance(self):
        server = PsychLanguageServer()
        uri = "file:///tmp/callback.lua"
        server.did_open({
            "textDocument": {
                "uri": uri,
                "text": "function onBeatHit()\nend\n",
            }
        })

        hover = server.hover({
            "textDocument": {"uri": uri},
            "position": {"line": 0, "character": 13},
        })
        value = hover["contents"]["value"]
        self.assertIn("Psych Engine callback", value)
        self.assertIn("cameraFlash", value)


if __name__ == "__main__":
    unittest.main()
