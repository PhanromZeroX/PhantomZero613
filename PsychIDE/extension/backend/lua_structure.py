"""Structural Lua checks that complement API and scope analysis."""

from typing import Dict, List, Tuple


_OPENERS = {"(": ")", "[": "]", "{": "}"}
_CLOSERS = {value: key for key, value in _OPENERS.items()}


class LuaStructureAnalyzer:
    def analyze(self, text: str) -> Tuple[List[Dict], List[Dict]]:
        errors: List[Dict] = []
        warnings: List[Dict] = []
        stack: List[Tuple[str, int, int]] = []
        block_stack: List[Tuple[str, int, int]] = []
        long_comment = False

        for line_no, line in enumerate(text.splitlines(), 1):
            index = 0
            quote = None
            while index < len(line):
                char = line[index]
                if long_comment:
                    end = line.find("]=" , index)
                    if end < 0:
                        index = len(line)
                        continue
                    long_comment = False
                    index = end + 2
                    continue
                if quote:
                    if char == "\\":
                        index += 2
                        continue
                    if char == quote:
                        quote = None
                    index += 1
                    continue
                if char in "'\"":
                    quote = char
                    index += 1
                    continue
                if line.startswith("--[[", index):
                    long_comment = True
                    index += 4
                    continue
                if char == "-" and index + 1 < len(line) and line[index + 1] == "-":
                    break
                if char in _OPENERS:
                    stack.append((char, line_no, index))
                elif char in _CLOSERS:
                    if not stack or stack[-1][0] != _CLOSERS[char]:
                        errors.append({
                            "line": line_no,
                            "col": index,
                            "length": 1,
                            "code": "psych-unmatched-delimiter",
                            "message": f"Unexpected closing delimiter: {char}",
                        })
                    else:
                        stack.pop()
                index += 1

            code = self._code_without_strings(line)
            keywords = ["function", "if", "for", "while", "repeat"]
            if self._has_word(code, "do") and not any(self._has_word(code, item) for item in ("if", "for", "while")):
                keywords.append("do")
            for keyword in keywords:
                if self._has_word(code, keyword):
                    block_stack.append((keyword, line_no, code.find(keyword)))
            for keyword in ("end", "until"):
                if self._has_word(code, keyword):
                    if not block_stack:
                        errors.append({
                            "line": line_no,
                            "col": code.find(keyword),
                            "length": len(keyword),
                            "code": "psych-unexpected-block-end",
                            "message": f"Unexpected block terminator: {keyword}",
                        })
                    else:
                        block_stack.pop()

            if quote:
                errors.append({
                    "line": line_no,
                    "col": line.find(quote),
                    "length": max(len(line) - line.find(quote), 1),
                    "code": "psych-unterminated-string",
                    "message": "Unterminated string literal.",
                })

        for opener, line_no, col in stack:
            errors.append({
                "line": line_no,
                "col": col,
                "length": 1,
                "code": "psych-unclosed-delimiter",
                "message": f"Unclosed delimiter: {opener}",
            })
        for keyword, line_no, col in block_stack:
            warnings.append({
                "line": line_no,
                "col": col,
                "length": len(keyword),
                "code": "psych-unclosed-block",
                "message": f"Block opened by '{keyword}' has no matching end.",
            })
        return errors, warnings

    def _code_without_strings(self, line: str) -> str:
        result = []
        quote = None
        index = 0
        while index < len(line):
            char = line[index]
            if quote:
                result.append(" ")
                if char == "\\":
                    if index + 1 < len(line):
                        result.append(" ")
                        index += 2
                        continue
                elif char == quote:
                    quote = None
            elif char in "'\"":
                quote = char
                result.append(" ")
            elif char == "-" and index + 1 < len(line) and line[index + 1] == "-":
                break
            else:
                result.append(char)
            index += 1
        return "".join(result)

    def _has_word(self, line: str, word: str) -> bool:
        return any(token == word for token in line.split())
