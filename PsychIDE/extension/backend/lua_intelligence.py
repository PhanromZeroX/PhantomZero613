"""Project-aware Lua symbol indexing for PsychIDE."""

from dataclasses import dataclass
from pathlib import Path
import re
from typing import Dict, Iterable, List, Optional
from urllib.parse import unquote, urlparse


_IDENTIFIER = r"[A-Za-z_][A-Za-z0-9_]*"
_DECLARATION_PATTERNS = (
    re.compile(r"\blocal\s+function\s+(%s)" % _IDENTIFIER),
    re.compile(r"\bfunction\s+(%s)" % _IDENTIFIER),
    re.compile(r"\b(?:local\s+)?(%s)\s*=" % _IDENTIFIER),
)
_CALL_PATTERN = re.compile(r"\b(%s)\s*(?=\()" % _IDENTIFIER)


@dataclass(frozen=True)
class LuaSymbol:
    name: str
    uri: str
    line: int
    character: int
    kind: int
    detail: str


class LuaIntelligenceIndex:
    """Indexes Lua declarations and references without executing project code."""

    def __init__(self) -> None:
        self.symbols: Dict[str, List[LuaSymbol]] = {}
        self.references: Dict[str, List[LuaSymbol]] = {}
        self.documents: Dict[str, str] = {}
        self.workspace_root: Optional[Path] = None

    @staticmethod
    def uri_to_path(uri: str) -> Optional[Path]:
        parsed = urlparse(uri)
        if parsed.scheme and parsed.scheme != "file":
            return None
        if parsed.scheme == "file":
            return Path(unquote(parsed.path))
        return Path(uri)

    @staticmethod
    def path_to_uri(path: Path) -> str:
        return path.resolve().as_uri()

    def set_workspace(self, root_uri: Optional[str]) -> None:
        self.workspace_root = self.uri_to_path(root_uri) if root_uri else None
        if self.workspace_root and self.workspace_root.is_file():
            self.workspace_root = self.workspace_root.parent
        self.rebuild()

    def rebuild(self) -> None:
        self.symbols.clear()
        self.references.clear()
        if not self.workspace_root or not self.workspace_root.exists():
            return
        ignored = {".git", ".buildozer", "node_modules", "out", "build", "dist", "__pycache__"}
        for path in self.workspace_root.rglob("*.lua"):
            if ignored.intersection(path.parts):
                continue
            try:
                self.update(self.path_to_uri(path), path.read_text(encoding="utf-8"))
            except (OSError, UnicodeError):
                continue

    def update(self, uri: str, text: str) -> None:
        self.remove(uri)
        self.documents[uri] = text
        for line_no, line in enumerate(text.splitlines(), 0):
            declared_name: Optional[str] = None
            for pattern in _DECLARATION_PATTERNS:
                match = pattern.search(line)
                if not match:
                    continue
                name = match.group(1)
                declared_name = name if "function" in pattern.pattern else None
                kind = 12 if "function" in pattern.pattern else 13
                detail = "function" if kind == 12 else "local variable"
                symbol = LuaSymbol(name, uri, line_no, match.start(1), kind, detail)
                self.symbols.setdefault(name, []).append(symbol)
                break

            for match in _CALL_PATTERN.finditer(line):
                name = match.group(1)
                if name == declared_name:
                    continue
                reference = LuaSymbol(name, uri, line_no, match.start(1), 3, "reference")
                self.references.setdefault(name, []).append(reference)

    def remove(self, uri: str) -> None:
        self.documents.pop(uri, None)
        for collection in (self.symbols, self.references):
            for name in list(collection):
                collection[name] = [item for item in collection[name] if item.uri != uri]
                if not collection[name]:
                    del collection[name]

    def definitions(self, name: str) -> List[LuaSymbol]:
        return list(self.symbols.get(name, []))

    def references_for(self, name: str) -> List[LuaSymbol]:
        return list(self.references.get(name, []))

    def symbols_for_uri(self, uri: str) -> List[LuaSymbol]:
        return [symbol for values in self.symbols.values() for symbol in values if symbol.uri == uri]

    def names(self, prefix: str = "") -> Iterable[str]:
        return sorted(name for name in self.symbols if name.startswith(prefix))

    def word_at(self, uri: str, line: int, character: int) -> Optional[str]:
        lines = self.documents.get(uri, "").splitlines()
        if line < 0 or line >= len(lines):
            return None
        current = lines[line]
        for match in re.finditer(r"\b%s\b" % _IDENTIFIER, current):
            if match.start() <= character <= match.end():
                return match.group(0)
        return None
