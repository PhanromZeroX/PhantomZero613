import contextlib
import io
import unittest

from psych_lsp import PsychLanguageServer


class DiagnosticsTests(unittest.TestCase):
    def test_validate_document_returns_coded_diagnostic(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.lua"
        with contextlib.redirect_stdout(io.StringIO()):
            result = server.validate_document({
                "textDocument": {
                    "uri": uri,
                    "text": "makeLuaSprite('only-one-argument')\n",
                }
            })

        self.assertEqual(len(result["errors"]), 1)
        diagnostic = result["errors"][0]
        self.assertEqual(diagnostic["code"], "psych-arity")
        self.assertEqual(diagnostic["line"], 1)
        self.assertGreater(diagnostic["length"], 0)

    def test_valid_document_has_no_diagnostics(self):
        server = PsychLanguageServer()
        with contextlib.redirect_stdout(io.StringIO()):
            result = server.validate_document({
                "textDocument": {
                    "uri": "file:///workspace/song.lua",
                    "text": "debugPrint('ready')\n",
                }
            })
        self.assertEqual(result, {"errors": [], "warnings": []})


if __name__ == "__main__":
    unittest.main()
