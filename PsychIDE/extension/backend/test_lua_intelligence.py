import tempfile
import unittest
from pathlib import Path

from lua_intelligence import LuaIntelligenceIndex
from psych_lsp import PsychLanguageServer


class LuaIntelligenceTests(unittest.TestCase):
    def test_indexes_project_declarations_and_references(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            declaration = root / "shared.lua"
            usage = root / "song.lua"
            declaration.write_text("function spawnNote(note)\nend\n", encoding="utf-8")
            usage.write_text("spawnNote('hey')\n", encoding="utf-8")

            index = LuaIntelligenceIndex()
            index.set_workspace(root.as_uri())

            self.assertEqual(len(index.definitions("spawnNote")), 1)
            self.assertEqual(len(index.references_for("spawnNote")), 1)
            self.assertEqual(index.definitions("spawnNote")[0].line, 0)

    def test_lsp_rename_groups_workspace_edits_by_uri(self):
        server = PsychLanguageServer()
        first_uri = "file:///workspace/first.lua"
        second_uri = "file:///workspace/second.lua"
        server.did_open({"textDocument": {"uri": first_uri, "text": "local target = 1\ntarget()\n"}})
        server.did_open({"textDocument": {"uri": second_uri, "text": "target()\n"}})

        result = server.rename({
            "textDocument": {"uri": first_uri},
            "position": {"line": 1, "character": 2},
            "newName": "renamed",
        })

        self.assertEqual(set(result["changes"]), {first_uri, second_uri})
        self.assertEqual(len(result["changes"][first_uri]), 2)
        self.assertEqual(len(result["changes"][second_uri]), 1)

    def test_incremental_change_preserves_unchanged_text(self):
        server = PsychLanguageServer()
        original = "local value = 1\nprint(value)\n"
        changed = server._apply_text_change(original, {
            "range": {
                "start": {"line": 0, "character": 14},
                "end": {"line": 0, "character": 15},
            },
            "text": "2",
        })
        self.assertEqual(changed, "local value = 2\nprint(value)\n")


if __name__ == "__main__":
    unittest.main()
