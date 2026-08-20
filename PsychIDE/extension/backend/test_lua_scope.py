import unittest

from lua_scope import LuaScopeAnalyzer


class LuaScopeTests(unittest.TestCase):
    def setUp(self):
        self.analyzer = LuaScopeAnalyzer()

    def test_reports_unresolved_reads(self):
        _, warnings = self.analyzer.analyze("local value = 1\nprint(value)\nprint(missing)\n")
        self.assertEqual([warning["code"] for warning in warnings], ["psych-undefined-variable"])
        self.assertEqual(warnings[0]["message"], "Undefined variable: missing")

    def test_accepts_locals_parameters_members_and_strings(self):
        errors, warnings = self.analyzer.analyze(
            "local value = 1\n"
            "local object = {}\n"
            "function use(value)\n"
            "  value = value + 1\n"
            "  object.value = 'missing'\n"
            "end\n"
        )
        self.assertEqual(errors, [])
        self.assertEqual(warnings, [])

    def test_accepts_known_engine_names(self):
        _, warnings = self.analyzer.analyze("debugPrint(screenWidth)\n", {"debugPrint", "screenWidth"})
        self.assertEqual(warnings, [])


if __name__ == "__main__":
    unittest.main()
