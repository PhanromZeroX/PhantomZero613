import contextlib
import io
import unittest

from psych_lsp import PsychLanguageServer


class _FakeAI:
    def __init__(self, response):
        self.response = response

    def ask_ai_to_fix(self, _error, _line):
        return self.response


class AISafetyTests(unittest.TestCase):
    def test_invalid_ai_patch_is_rejected(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.lua"
        with contextlib.redirect_stdout(io.StringIO()):
            server.did_open({"textDocument": {"uri": uri, "text": "debugPrint('ok')\n"}})
        server.ai_client = _FakeAI({"fixed_code": "makeLuaSprite('only-one-argument')"})

        response = server.execute_command({
            "command": "psychIde.askAiToFix",
            "arguments": [uri, 0],
        })

        self.assertIn("error", response)
        self.assertIn("violates PsychIDE rules", response["error"])

    def test_valid_ai_patch_is_returned_with_explanation(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.lua"
        with contextlib.redirect_stdout(io.StringIO()):
            server.did_open({"textDocument": {"uri": uri, "text": "debugPrint()\n"}})
        server.ai_client = _FakeAI({
            "explanation": "The message argument was missing.",
            "fixed_code": "debugPrint('ok')",
        })

        response = server.execute_command({
            "command": "psychIde.askAiToFix",
            "arguments": [uri, 0],
        })

        self.assertEqual(response["fixed_code"], "debugPrint('ok')")
        self.assertEqual(response["explanation"], "The message argument was missing.")


if __name__ == "__main__":
    unittest.main()
