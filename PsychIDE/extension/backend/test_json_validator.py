import tempfile
import unittest
from pathlib import Path

from json_validator import JsonValidator


class JsonValidatorTests(unittest.TestCase):
    def test_duplicate_key_is_reported(self):
        errors, warnings = JsonValidator().validate("file:///song.json", '{"song": 1, "song": 2}')
        self.assertEqual(errors[0]["code"], "psych-json-duplicate-key")
        self.assertEqual(warnings, [])

    def test_workspace_schema_checks_required_and_types(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "schemas").mkdir()
            (root / "schemas" / "song.schema.json").write_text(
                '{"type":"object","required":["song"],"properties":{"song":{"type":"string"}}}',
                encoding="utf-8",
            )
            validator = JsonValidator(root)
            errors, _ = validator.validate((root / "song.json").as_uri(), '{"song": 42}')
        self.assertEqual([error["code"] for error in errors], ["psych-json-type"])

    def test_non_object_root_is_rejected(self):
        errors, _ = JsonValidator().validate("file:///song.json", "[]")
        self.assertEqual(errors[0]["code"], "psych-json-root")


if __name__ == "__main__":
    unittest.main()
