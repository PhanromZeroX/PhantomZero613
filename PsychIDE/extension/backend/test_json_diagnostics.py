import contextlib
import io
import unittest

from psych_lsp import PsychLanguageServer


class JsonDiagnosticsTests(unittest.TestCase):
    def test_invalid_json_has_precise_server_diagnostic(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.json"
        with contextlib.redirect_stdout(io.StringIO()):
            result = server.validate_document({
                "textDocument": {"uri": uri, "text": '{"song": }\n'},
            })
        self.assertEqual(len(result["errors"]), 1)
        self.assertEqual(result["errors"][0]["code"], "psych-json-syntax")
        self.assertEqual(result["errors"][0]["line"], 1)
        self.assertGreaterEqual(result["errors"][0]["col"], 1)

    def test_valid_json_has_no_server_diagnostics(self):
        server = PsychLanguageServer()
        with contextlib.redirect_stdout(io.StringIO()):
            result = server.validate_document({
                "textDocument": {"uri": "file:///workspace/song.json", "text": '{"song": "test"}'},
            })
        self.assertEqual(result, {"errors": [], "warnings": []})


if __name__ == "__main__":
    unittest.main()
