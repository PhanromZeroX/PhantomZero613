"""Conservative lexical-scope analysis for Lua diagnostics."""

import re
from typing import Dict, Iterable, List, Set, Tuple


_TOKEN = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
    "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then",
    "true", "until", "while", "self",
}
_BUILTINS = {
    "assert", "collectgarbage", "dofile", "error", "getmetatable", "ipairs", "load",
    "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require",
    "select", "setmetatable", "tonumber", "tostring", "type", "xpcall", "_G", "_VERSION",
}


class LuaScopeAnalyzer:
    def analyze(self, text: str, known_names: Iterable[str] = ()) -> Tuple[List[Dict], List[Dict]]:
        errors: List[Dict] = []
        warnings: List[Dict] = []
        scopes: List[Set[str]] = [set(known_names) | _BUILTINS]
        lines = text.splitlines()

        for line_no, raw_line in enumerate(lines, 1):
            line = self._strip_comments_and_strings(raw_line)
            self._declare_function_parameters(line, scopes)
            self._declare_locals(line, scopes[-1])
            self._declare_loop_variables(line, scopes[-1])

            for match in _TOKEN.finditer(line):
                name = match.group(0)
                if name in _KEYWORDS or self._is_member_or_declaration(line, match.start()):
                    continue
                if self._is_write_target(line, match.start()) or self._is_function_call(line, match.end()):
                    continue
                if not any(name in scope for scope in reversed(scopes)):
                    warnings.append({
                        "line": line_no,
                        "col": match.start(),
                        "length": len(name),
                        "code": "psych-undefined-variable",
                        "message": f"Undefined variable: {name}",
                    })

            if re.search(r"\b(function|if|for|while|do|repeat)\b", line):
                scopes.append(set())
            if re.search(r"\b(end|until)\b", line) and len(scopes) > 1:
                scopes.pop()

        return errors, self._deduplicate(warnings)

    def _declare_locals(self, line: str, scope: Set[str]) -> None:
        match = re.search(r"\blocal\s+((?:[A-Za-z_]\w*\s*,?\s*)+)(?:=|$)", line)
        if match:
            scope.update(re.findall(r"[A-Za-z_]\w*", match.group(1)))

    def _declare_function_parameters(self, line: str, scopes: List[Set[str]]) -> None:
        match = re.search(r"\bfunction\s+[A-Za-z_]\w*\s*\(([^)]*)\)", line)
        if match:
            scopes[-1].update(re.findall(r"[A-Za-z_]\w*", match.group(1)))

    def _declare_loop_variables(self, line: str, scope: Set[str]) -> None:
        match = re.search(r"\bfor\s+([A-Za-z_]\w*)", line)
        if match:
            scope.add(match.group(1))

    def _is_member_or_declaration(self, line: str, start: int) -> bool:
        return start > 0 and line[start - 1] in ".:"

    def _is_write_target(self, line: str, start: int) -> bool:
        suffix = line[start:]
        return bool(re.match(r"[A-Za-z_]\w*\s*=", suffix))

    def _is_function_call(self, line: str, end: int) -> bool:
        return bool(re.match(r"\s*\(", line[end:]))

    def _strip_comments_and_strings(self, line: str) -> str:
        result = []
        quote = None
        index = 0
        while index < len(line):
            char = line[index]
            if quote:
                if char == quote and (index == 0 or line[index - 1] != "\\"):
                    quote = None
                result.append(" ")
            elif char in "'\"":
                quote = char
                result.append(" ")
            elif char == "-" and index + 1 < len(line) and line[index + 1] == "-":
                break
            else:
                result.append(char)
            index += 1
        return "".join(result)

    def _deduplicate(self, diagnostics: List[Dict]) -> List[Dict]:
        seen = set()
        result = []
        for diagnostic in diagnostics:
            key = (diagnostic["line"], diagnostic["col"], diagnostic["message"])
            if key not in seen:
                seen.add(key)
                result.append(diagnostic)
        return result
