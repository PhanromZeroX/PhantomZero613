"""Schema-aware JSON diagnostics with safe fallbacks."""

import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


class JsonValidator:
    def __init__(self, workspace_root: Optional[Path] = None) -> None:
        self.workspace_root = workspace_root

    def set_workspace(self, workspace_root: Optional[Path]) -> None:
        self.workspace_root = workspace_root

    def validate(self, uri: str, text: str) -> Tuple[List[Dict], List[Dict]]:
        errors: List[Dict] = []
        warnings: List[Dict] = []
        try:
            value = json.loads(text, object_pairs_hook=self._duplicate_keys(errors))
        except json.JSONDecodeError as error:
            return [{
                "line": error.lineno,
                "col": max(error.colno - 1, 0),
                "length": 1,
                "code": "psych-json-syntax",
                "message": f"JSON syntax error: {error.msg}",
            }], []

        if not isinstance(value, dict):
            errors.append({
                "line": 1,
                "col": 0,
                "length": 1,
                "code": "psych-json-root",
                "message": "Psych Engine project JSON must have an object at the root.",
            })
            return errors, warnings

        schema = self._load_schema(uri)
        if schema:
            self._validate_schema(value, schema, errors, warnings, "")
        return errors, warnings

    def _duplicate_keys(self, errors: List[Dict]):
        def hook(pairs):
            result = {}
            for key, value in pairs:
                if key in result:
                    errors.append({
                        "line": 1,
                        "col": 0,
                        "length": len(key),
                        "code": "psych-json-duplicate-key",
                        "message": f"Duplicate JSON key: {key}",
                    })
                result[key] = value
            return result
        return hook

    def _load_schema(self, uri: str) -> Optional[Dict[str, Any]]:
        name = Path(uri.split("?")[0]).name
        if not self.workspace_root or name not in {"song.json", "character.json"}:
            return None
        candidates = [
            self.workspace_root / name.replace(".json", ".schema.json"),
            self.workspace_root / "schemas" / name.replace(".json", ".schema.json"),
            self.workspace_root / ".psychide" / "schemas" / name.replace(".json", ".schema.json"),
        ]
        for candidate in candidates:
            try:
                if candidate.is_file():
                    return json.loads(candidate.read_text(encoding="utf-8"))
            except (OSError, UnicodeDecodeError, json.JSONDecodeError):
                return None
        return None

    def _validate_schema(self, value: Any, schema: Dict[str, Any], errors: List[Dict], warnings: List[Dict], path: str) -> None:
        expected = schema.get("type")
        if expected and not self._matches_type(value, expected):
            errors.append({
                "line": 1, "col": 0, "length": 1, "code": "psych-json-type",
                "message": f"{path or 'Root'} must be {expected}.",
            })
            return
        if isinstance(value, dict):
            for required in schema.get("required", []):
                if required not in value:
                    errors.append({
                        "line": 1, "col": 0, "length": len(required), "code": "psych-json-required",
                        "message": f"Missing required property: {path + '.' if path else ''}{required}",
                    })
            for key, child_schema in schema.get("properties", {}).items():
                if key in value and isinstance(child_schema, dict):
                    self._validate_schema(value[key], child_schema, errors, warnings, f"{path}.{key}" if path else key)

    def _matches_type(self, value: Any, expected: str) -> bool:
        return {
            "object": isinstance(value, dict),
            "array": isinstance(value, list),
            "string": isinstance(value, str),
            "number": isinstance(value, (int, float)) and not isinstance(value, bool),
            "integer": isinstance(value, int) and not isinstance(value, bool),
            "boolean": isinstance(value, bool),
            "null": value is None,
        }.get(expected, True)
