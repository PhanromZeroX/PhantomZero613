import unittest

from lua_structure import LuaStructureAnalyzer


class LuaStructureTests(unittest.TestCase):
    def setUp(self):
        self.analyzer = LuaStructureAnalyzer()

    def test_reports_unclosed_delimiter(self):
        errors, _ = self.analyzer.analyze("local value = {1, 2\n")
        self.assertEqual(errors[0]["code"], "psych-unclosed-delimiter")

    def test_reports_unexpected_delimiter(self):
        errors, _ = self.analyzer.analyze("local value = 1)\n")
        self.assertEqual(errors[0]["code"], "psych-unmatched-delimiter")

    def test_ignores_strings_and_comments(self):
        errors, warnings = self.analyzer.analyze(
            "local text = 'not (a delimiter)' -- ]\n"
            "print(text)\n"
        )
        self.assertEqual(errors, [])
        self.assertEqual(warnings, [])

    def test_reports_unterminated_string(self):
        errors, _ = self.analyzer.analyze("print('unfinished)\n")
        self.assertEqual(errors[0]["code"], "psych-unterminated-string")

    def test_reports_unclosed_function_block(self):
        _, warnings = self.analyzer.analyze("function onCreate()\nprint('ok')\n")
        self.assertEqual(warnings[0]["code"], "psych-unclosed-block")


if __name__ == "__main__":
    unittest.main()
