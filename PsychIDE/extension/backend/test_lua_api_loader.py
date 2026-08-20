import tempfile
import unittest
from pathlib import Path

from lua_api_loader import LuaApiLoader


class LuaApiLoaderTests(unittest.TestCase):
    def test_loads_parameter_types_and_callbacks(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "PsychEngine_Globals.lua").write_text(
                "---@param tag string\n"
                "---@param amount number\n"
                "---@return boolean\n"
                "function engineCall(tag, amount) end\n"
                "---@param elapsed number\n"
                "function onUpdate(elapsed) end\n",
                encoding="utf-8",
            )
            api = LuaApiLoader().load_workspace_api(root)

        self.assertEqual(api["functions"][0]["name"], "engineCall")
        self.assertEqual(api["functions"][0]["args"][1]["type"], "number")
        self.assertEqual(api["functions"][0]["return"], "boolean")
        self.assertEqual(api["callbacks"][0]["name"], "onUpdate")

    def test_missing_stub_is_empty(self):
        with tempfile.TemporaryDirectory() as directory:
            api = LuaApiLoader().load_workspace_api(Path(directory))
        self.assertEqual(api, {"functions": [], "callbacks": []})


if __name__ == "__main__":
    unittest.main()
