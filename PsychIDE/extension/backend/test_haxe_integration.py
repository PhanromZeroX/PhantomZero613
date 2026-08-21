import tempfile
import unittest
from pathlib import Path

from psych_lsp import PsychLanguageServer


class HaxeIntegrationTests(unittest.TestCase):
    def test_workspace_reindex_discovers_haxe_symbols(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source" / "GameState.hx"
            source.parent.mkdir()
            source.write_text(
                "class GameState {\n"
                "  public static function reset(value:Int):Void {}\n"
                "}\n",
                encoding="utf-8",
            )
            server = PsychLanguageServer()
            result = server.initialize({"rootUri": root.as_uri()})
            self.assertEqual(result["capabilities"]["workspaceSymbolProvider"], True)
            self.assertEqual(len(server.haxe_api["classes"]), 1)
            self.assertEqual(len(server.haxe_api["functions"]), 1)
            symbols = server.workspace_symbols({"query": "GameState"})
            self.assertTrue(any(symbol["name"] == "GameState" for symbol in symbols))
            self.assertGreaterEqual(server.reindex_workspace({})["haxeFunctions"], 1)

    def test_haxe_parser_extracts_package_imports_fields_and_optional_return(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source" / "GameState.hx"
            source.parent.mkdir()
            source.write_text(
                "package game.state;\nimport flixel.FlxSprite;\n"
                "class GameState {\n"
                "  public var score:Int;\n"
                "  public static function reset(value:Array<Int>):Void {}\n"
                "}\n",
                encoding="utf-8",
            )
            from haxe_parser import HaxeParser
            result = HaxeParser(str(root)).extract_all_apis()
            self.assertIn("flixel.FlxSprite", result["imports"])
            self.assertEqual(result["fields"][0]["name"], "score")
            self.assertEqual(result["functions"][0]["params"][0]["type"], "Array<Int>")


if __name__ == "__main__":
    unittest.main()
