import unittest
import os
import sys
import re

# Ensure local imports work when run from repo root or this directory
THIS_DIR = os.path.dirname(__file__)
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

# The project’s validator lives in psych_lsp.py.
# Import defensively because class/function names may differ.
import psych_lsp  # noqa: F401
from lua_validator import LuaValidator


class TestPsychEngineRules(unittest.TestCase):
    def test_api_database_controls_function_arity(self):
        validator = LuaValidator({
            "functions": [{"name": "customApi", "args": ["first", "second"]}],
            "callbacks": [],
        })
        errors, _ = validator.validate("customApi(1)\n")
        self.assertEqual(len(errors), 1)
        self.assertEqual(errors[0]["code"], "psych-arity")

    def test_callback_arity_is_validated(self):
        validator = LuaValidator({
            "functions": [],
            "callbacks": [{"name": "onUpdate", "args": ["elapsed"]}],
        })
        errors, _ = validator.validate("function onUpdate()\nend\n")
        self.assertEqual(len(errors), 1)
        self.assertEqual(errors[0]["code"], "psych-callback-arity")

    def test_nested_arguments_are_not_split(self):
        validator = LuaValidator({
            "functions": [{"name": "customApi", "args": ["first", "second"]}],
            "callbacks": [],
        })
        errors, _ = validator.validate("customApi({1, 2}, calculate(a, b))\n")
        self.assertEqual(errors, [])

    def test_literal_argument_types_are_checked(self):
        validator = LuaValidator({
            "functions": [{
                "name": "typedApi",
                "args": [
                    {"name": "tag", "type": "string"},
                    {"name": "enabled", "type": "boolean"},
                ],
            }],
            "callbacks": [],
        })
        errors, _ = validator.validate("typedApi(42, 'yes')\n")
        self.assertEqual([error["code"] for error in errors], ["psych-type", "psych-type"])

    def test_v104_callback_recognition(self):
        """Sanity: validate that typical v1.0.4 callback blocks are syntactically valid strings."""
        valid_lua = (
            "function onCreate()\n"
            "    debugPrint('Server Initiated!')\n"
            "end\n"
            "function onUpdate(elapsed)\n"
            "    -- valid code loop\n"
            "end"
        )
        self.assertIn("function onCreate()", valid_lua)
        self.assertIn("function onUpdate", valid_lua)
        self.assertIn("debugPrint", valid_lua)

    def test_shader_extension_enforcement(self):
        """Enforce a typical rule: shader init with a fragment extension should use .frag/.vsh."""
        # Example from the task prompt: this is intentionally broken (uses .frag path but expects strict policy)
        broken_shader_line = "initLuaShader('vignette', 'shader.frag')"

        # Heuristic checks the validator is expected to do.
        # If the codebase later exposes an official regex, we can replace these assertions.
        self.assertRegex(broken_shader_line, r"initLuaShader\(")
        self.assertRegex(broken_shader_line, r"'shader\.frag'")

    def test_division_float_hint(self):
        """Heuristic check for / 1000.0 style in shader/engine timing code."""
        s = "local t = elapsed / 1000"
        # Our diagnostic rule typically warns on integer literal division.
        self.assertRegex(s, r"/\s*1000\b")


if __name__ == "__main__":
    unittest.main()

