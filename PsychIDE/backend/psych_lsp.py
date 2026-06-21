"""
Psych Engine Language Server Protocol (LSP) implementation.
Provides autocompletion, diagnostics, and hover information for Psych modding.
"""

import json
import sys
from typing import Dict, Any, List, Optional

from lua_validator import LuaValidator



class PsychLanguageServer:
    def __init__(self):
        self.validator = LuaValidator()
        self.log_path = "/tmp/psych_ide_lsp.log"

        self.methods = {
            "initialize": self.initialize,
            "initialized": self.initialized,
            "textDocument/didOpen": self.did_open,
            "textDocument/didChange": self.did_change,
            "textDocument/completion": self.completion,
            "textDocument/hover": self.hover,
        }

    def _log(self, payload: Any) -> None:
        try:
            with open(self.log_path, "a", encoding="utf-8") as f:
                f.write(str(payload) + "\n")
        except Exception:
            # Never crash the LSP due to logging
            pass

    def initialize(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Initialize the language server"""
        # Null guard: single-file mode may pass rootUri = null
        _ = params.get("rootUri")

        return {
            "capabilities": {
                "textDocumentSync": 2,  # Full document sync
                "completionProvider": {
                    "resolveProvider": True,
                    "triggerCharacters": [".", "(", " "],
                },
                "hoverProvider": True,
                "diagnosticProvider": True,
                "semanticTokensProvider": {
                    "legend": {
                        "tokenTypes": ["variable", "function", "keyword", "string", "number", "type"],
                        "tokenModifiers": [],
                    },
                    "full": True,
                    "range": True,
                },
            }
        }

    def initialized(self, _params: Dict[str, Any]) -> None:
        # Handshake completion handler (empty by design)
        return None

    def did_open(self, params: Dict[str, Any]) -> None:
        """Handle document open"""
        uri = params["textDocument"]["uri"]
        text = params["textDocument"]["text"]
        self._validate_document(uri, text)

    def did_change(self, params: Dict[str, Any]) -> None:
        """Handle document changes"""
        uri = params["textDocument"]["uri"]
        changes = params.get("contentChanges", [])
        if changes:
            text = changes[-1]["text"]
            self._validate_document(uri, text)

    def _validate_document(self, uri: str, text: str) -> None:
        """Validate a Lua document"""
        if not uri.endswith(".lua"):
            return

        errors, warnings = self.validator.validate(text)
        self._log(f"Diagnostics for {uri}: {len(errors)} errors, {len(warnings)} warnings")

    def completion(self, params: Dict[str, Any]) -> Dict[str, List[Dict]]:
        """Provide autocompletion suggestions"""
        _line = params["textDocument"]["position"]["line"]
        _char = params["textDocument"]["position"]["character"]

        completions: List[Dict[str, Any]] = []

        for func_name, spec in self.validator.PSYCH_FUNCTIONS.items():
            params_str = ", ".join(spec["params"])
            completions.append(
                {
                    "label": func_name,
                    "kind": 3,
                    "detail": f"{func_name}({params_str}): {spec['return']}",
                    "insertText": f"{func_name}($0)",
                }
            )

        for var_name, var_type in self.validator.PSYCH_GLOBALS.items():
            completions.append(
                {
                    "label": var_name,
                    "kind": 25,
                    "detail": f"Global: {var_type}",
                    "insertText": var_name,
                }
            )

        return {"isIncomplete": False, "items": completions}

    def hover(self, params: Dict[str, Any]) -> Dict[str, str]:
        """Provide hover information"""
        return {"contents": "Psych Engine API documentation available at docs/"}

    def handle_request(self, method: str, params: Dict[str, Any]) -> Any:
        """Handle an RPC request"""
        handler = self.methods.get(method)
        if handler:
            return handler(params)
        return None



def _read_lsp_message(stdin) -> Optional[Dict[str, Any]]:
    """Read a single JSON-RPC message from stdin using LSP Content-Length framing."""
    headers: Dict[str, str] = {}

    # Read headers until blank line
    while True:
        line = stdin.readline()
        if line == "":
            return None  # EOF
        line = line.rstrip("\r\n")
        if line == "":
            break

        if ":" in line:
            k, v = line.split(":", 1)
            headers[k.strip().lower()] = v.strip()

    length_str = headers.get("content-length")
    if not length_str:
        return None

    try:
        length = int(length_str)
    except ValueError:
        return None

    body = stdin.read(length)
    if body is None or body == "":
        return None

    return json.loads(body)


def _write_lsp_response(stdout, request_id: Any, result: Any) -> None:
    payload = {"jsonrpc": "2.0", "id": request_id, "result": result}
    data = json.dumps(payload)
    header = f"Content-Length: {len(data)}\r\n\r\n"
    stdout.write(header)
    stdout.write(data)
    stdout.flush()


def main():
    """Main LSP loop"""
    server = PsychLanguageServer()
    stdin = sys.stdin
    stdout = sys.stdout

    while True:
        try:
            msg = _read_lsp_message(stdin)
            if msg is None:
                break

            server._log(msg)
            method = msg.get("method")
            params = msg.get("params", {})
            req_id = msg.get("id")

            if not method:
                continue

            result = server.handle_request(method, params)

            # Only reply when there is an id (requests). Notifications have no id.
            if req_id is not None:
                _write_lsp_response(stdout, req_id, result)
        except EOFError:
            break
        except Exception as e:
            server._log({"error": str(e)})



if __name__ == '__main__':
    main()
