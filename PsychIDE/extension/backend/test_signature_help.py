import contextlib
import io
import unittest

from psych_lsp import PsychLanguageServer


class SignatureHelpTests(unittest.TestCase):
    def setUp(self):
        self.server = PsychLanguageServer()
        self.server.initialize({"rootUri": "file:///workspaces/PhantomZero613"})
        self.uri = "file:///workspaces/PhantomZero613/test-signature.lua"

    def signature_at(self, text, character):
        with contextlib.redirect_stdout(io.StringIO()):
            self.server.did_open({"textDocument": {"uri": self.uri, "text": text}})
        return self.server.signature_help({
            "textDocument": {"uri": self.uri},
            "position": {"line": 0, "character": character},
        })

    def test_reports_active_typed_parameter(self):
        text = "makeLuaSprite('bg', 10, 20, 0"
        result = self.signature_at(text, len(text))
        self.assertEqual(result["activeParameter"], 3)
        self.assertIn("id: string", result["signatures"][0]["label"])
        self.assertIn("x: number", result["signatures"][0]["label"])

    def test_ignores_nested_commas(self):
        text = "makeLuaSprite(calculate('bg', 1), 10"
        result = self.signature_at(text, len(text))
        self.assertEqual(result["activeParameter"], 1)

    def test_unknown_call_has_no_signature(self):
        result = self.signature_at("unknownFunction(1", len("unknownFunction(1"))
        self.assertIsNone(result)


if __name__ == "__main__":
    unittest.main()
