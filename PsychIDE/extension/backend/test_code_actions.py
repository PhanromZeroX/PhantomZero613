import contextlib
import io
import unittest

from psych_lsp import PsychLanguageServer


class CodeActionTests(unittest.TestCase):
    def test_shader_extension_fix_returns_workspace_edit(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.lua"
        text = "initLuaShader('heatwave.frag')\n"
        with contextlib.redirect_stdout(io.StringIO()):
            result = server.validate_document({
                "textDocument": {"uri": uri, "text": text},
            })
        diagnostic = result["errors"][0]
        self.assertEqual(diagnostic["code"], "psych-shader-name")

        actions = server.code_action({
            "textDocument": {"uri": uri},
            "range": {"start": {"line": 0, "character": 0}},
            "context": {"diagnostics": [{
                "code": diagnostic["code"],
                "message": diagnostic["message"],
            }]},
        })

        fix = next(action for action in actions if action["kind"] == "quickfix")
        edit = fix["edit"]["changes"][uri][0]
        self.assertEqual(edit["newText"], "heatwave")
        self.assertEqual(edit["range"]["start"]["character"], 15)
        self.assertEqual(edit["range"]["end"]["character"], 28)

    def test_unrelated_diagnostic_has_no_shader_fix(self):
        server = PsychLanguageServer()
        uri = "file:///workspace/song.lua"
        server.document_manager[uri] = "debugPrint('ready')\n"
        actions = server.code_action({
            "textDocument": {"uri": uri},
            "range": {"start": {"line": 0, "character": 0}},
            "context": {"diagnostics": [{"code": "psych-arity", "message": "bad args"}]},
        })
        self.assertFalse(any(action.get("kind") == "quickfix" for action in actions))


if __name__ == "__main__":
    unittest.main()
