import contextlib
import io
import unittest

from psych_lsp import PsychLanguageServer


class WorkspaceLifecycleTests(unittest.TestCase):
    def test_closed_document_is_removed_from_index(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.lua"
        with contextlib.redirect_stdout(io.StringIO()):
            server.did_open({
                "textDocument": {
                    "uri": uri,
                    "text": "function projectCallback()\nend\n",
                }
            })
        self.assertEqual(len(server.index.definitions("projectCallback")), 1)

        with contextlib.redirect_stdout(io.StringIO()):
            server.did_close({"textDocument": {"uri": uri}})
        self.assertEqual(server.index.definitions("projectCallback"), [])
        self.assertNotIn(uri, server.document_manager)
        self.assertNotIn(uri, server.last_diagnostics)

    def test_reindex_reports_current_index_counts(self):
        server = PsychLanguageServer()
        server.index.documents["file:///workspace/stale.lua"] = "stale"
        result = server.reindex_workspace({})
        self.assertTrue(result["ok"])
        self.assertIn("documents", result)
        self.assertIn("symbols", result)
        self.assertIn("apiFunctions", result)
        self.assertIn("apiCallbacks", result)


if __name__ == "__main__":
    unittest.main()
