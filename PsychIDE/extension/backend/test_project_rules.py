import tempfile
import unittest
from pathlib import Path

from project_rules import ProjectRules


class ProjectRulesTests(unittest.TestCase):
    def test_duplicate_callback_is_an_error(self):
        errors, warnings = ProjectRules().validate(
            "file:///tmp/song.lua",
            "function onCreate()\nend\nfunction onCreate()\nend\n",
        )
        self.assertEqual(len(errors), 1)
        self.assertIn("Duplicate lifecycle callback", errors[0]["message"])
        self.assertEqual(warnings, [])

    def test_missing_shader_is_a_warning(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "shaders").mkdir()
            errors, warnings = ProjectRules(root).validate(
                "file:///tmp/song.lua",
                "initLuaShader('missing_shader')\n",
            )
        self.assertEqual(errors, [])
        self.assertEqual(len(warnings), 1)
        self.assertIn("Shader asset not found", warnings[0]["message"])

    def test_existing_shader_is_allowed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "shaders").mkdir()
            (root / "shaders" / "heatwave.frag").write_text("void main() {}", encoding="utf-8")
            errors, warnings = ProjectRules(root).validate(
                "file:///tmp/song.lua",
                "initLuaShader('heatwave')\n",
            )
        self.assertEqual(errors, [])
        self.assertEqual(warnings, [])

    def test_missing_image_and_audio_are_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "images").mkdir()
            (root / "sounds").mkdir()
            errors, warnings = ProjectRules(root).validate(
                "file:///tmp/song.lua",
                "makeLuaSprite('bg', 'stage/missing')\nplaySound('missing')\n",
            )
        self.assertEqual(errors, [])
        self.assertEqual({warning["code"] for warning in warnings}, {
            "psych-missing-image",
            "psych-missing-audio",
        })

    def test_existing_image_and_audio_are_allowed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "images" / "stage").mkdir(parents=True)
            (root / "sounds").mkdir()
            (root / "images" / "stage" / "bg.png").write_bytes(b"image")
            (root / "sounds" / "hit.ogg").write_bytes(b"audio")
            errors, warnings = ProjectRules(root).validate(
                "file:///tmp/song.lua",
                "makeLuaSprite('bg', 'stage/bg')\nplaySound('hit')\n",
            )
        self.assertEqual(errors, [])
        self.assertEqual(warnings, [])


if __name__ == "__main__":
    unittest.main()
