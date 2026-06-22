"""
Psych Engine Language Server Protocol (LSP) implementation.
Provides autocompletion, diagnostics, and hover information for Psych modding.
"""

import json
import sys
import logging
import traceback
import os
import re
from datetime import datetime
import threading
from typing import Dict, Any, List, Optional

from lua_validator import LuaValidator


import pathlib


class PsychLanguageServer:
    def __init__(self):
        self.validator = LuaValidator()
        self.last_diagnostics = {} # The "Memory" for errors
        self.document_manager = {} # The "Memory" for file content
        self.log_path = "/tmp/psych_ide_lsp.log"
        self.debounce_timer = None
        self.debounce_interval = 0.3

        # Load Psych Engine v1.0.4 API database (callbacks/functions)
        current_dir = os.path.dirname(os.path.abspath(__file__))
        self.api_db_path = os.path.join(current_dir, "psych_api.json")
        self.api_db: Dict[str, Any] = {"callbacks": [], "functions": []}
        try:
            if os.path.exists(self.api_db_path):
                with open(self.api_db_path, "r", encoding="utf-8") as f:
                    self.api_db = json.load(f)
        except Exception:
            # Never crash LSP due to api DB load failure
            self.api_db = {"callbacks": [], "functions": []}

        # Robust crash logging for hidden failures
        # Robust crash logging for hidden failures
        self.crash_log_file = os.path.join(current_dir, "server_crash.log")
        try:
            os.makedirs(os.path.dirname(self.crash_log_file), exist_ok=True)
        except Exception:
            pass

        logging.basicConfig(
            filename=self.crash_log_file,
            level=logging.DEBUG,
            format='%(asctime)s - %(levelname)s - %(message)s',
        )


        self.methods = {
            "initialize": self.initialize,
            "initialized": self.initialized,
            "textDocument/didOpen": self.did_open,
            "textDocument/didChange": self.did_change,
            "textDocument/didSave": self.did_save,
            "textDocument/completion": self.completion,
            "textDocument/hover": self.hover,
            "textDocument/semanticTokens/full": self.get_semantic_tokens
        }

    def publish_diagnostics(self, uri: str, errors: List[Any], warnings: List[Any]):
        """Push diagnostics to VS Code with debug logging"""
        diagnostics = []
        
        # 🔴 Process Errors (Red Squiggles)
        for err in errors:
            self._log(f"DEBUG Error: {err}")
            # Use .get() for dictionaries, and subtract 1 for VS Code's 0-based lines
            line = err.get('line', err.get('row', 1)) - 1 
            col = err.get('col', err.get('column', 0))
            msg = err.get('message', err.get('msg', 'Unknown Error'))

            diagnostics.append({
                "range": {
                    "start": {"line": line, "character": col},
                    "end": {"line": line, "character": col + 15} # Give the squiggle some width
                },
                "severity": 1, # 1 = Error
                "message": msg
            })
            
        # 🟡 Process Warnings (Yellow Squiggles)
        for warn in warnings:
            self._log(f"DEBUG Warning: {warn}")
            line = warn.get('line', warn.get('row', 1)) - 1
            col = warn.get('col', warn.get('column', 0))
            msg = warn.get('message', warn.get('msg', 'Unknown Warning'))

            diagnostics.append({
                "range": {
                    "start": {"line": line, "character": col},
                    "end": {"line": line, "character": col + 15}
                },
                "severity": 2, # 2 = Warning
                "message": msg
            })
        
        payload = {
            "jsonrpc": "2.0",
            "method": "textDocument/publishDiagnostics",
            "params": {
                "uri": uri,
                "diagnostics": diagnostics
            }
        }
        
        data = json.dumps(payload)
        header = f"Content-Length: {len(data)}\r\n\r\n"
        sys.stdout.write(header + data)
        sys.stdout.flush()


    def _log(self, payload: Any) -> None:
        try:
            # Create a formatted timestamp like [2026-06-21 23:05:47]
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            with open(self.log_path, "a", encoding="utf-8") as f:
                f.write(f"[{timestamp}] {payload}\n")
        except Exception:
            # Never crash the LSP due to logging
            pass

    def initialize(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Initialize the language server"""
        # Null guard: single-file mode may pass rootUri = null
        root_uri = params.get("rootUri")
        try:
            logging.info(f"initialize called (rootUri={root_uri})")
        except Exception:
            pass

        return {

            "capabilities": {
                "textDocumentSync": 1,  # Full document sync
                "completionProvider": {
                    "resolveProvider": True,
                    "triggerCharacters": [".", "(", " "],
                },
                "hoverProvider": True,
                "diagnosticProvider": True,
                "semanticTokensProvider": {
                    "legend": {
                        "tokenTypes": ["variable", "function", "keyword", "string", "number", "type", "engine"],
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
        
        # Add this line to ensure the document manager knows the file content
        self.document_manager[uri] = text 
        
        self._validate_document(uri, text)

    def on_did_change(self, params: Dict[str, Any]) -> None:
        """Handles the debounced validation trigger."""
        # If a timer is already running, cancel it
        if self.debounce_timer:
            self.debounce_timer.cancel()
    
        # Start a new timer to wait for the user to stop typing
        self.debounce_timer = threading.Timer(self.debounce_interval, self.validate_and_publish, [params])
        self.debounce_timer.start()


    def did_change(self, params: Dict[str, Any]) -> None:
        """Handle document changes from VS Code"""
        uri = params["textDocument"]["uri"]
        # Update our document manager with the latest full text
        for change in params.get("contentChanges", []):
            self.document_manager[uri] = change.get("text", "")
        
        # Trigger the debounced validation
        self.on_did_change(params)

    def did_save(self, params: Dict[str, Any]) -> None:
        """Handle document save - force run immediate evaluation to counter Client Wipes"""
        if self.debounce_timer:
            self.debounce_timer.cancel()
        
        self.validate_and_publish(params)

    def validate_and_publish(self, params):
        uri = params["textDocument"]["uri"]
        text = self.document_manager.get(uri, "")
        
        # 1. Run the validator scan on the full, uncorrupted text
        errors, warnings = self.validator.validate(text)
        
        # 2. Update the cache and push the real updates directly to VS Code
        self.last_diagnostics[uri] = (errors, warnings)
        self.publish_diagnostics(uri, errors, warnings)

    def _validate_document(self, uri: str, text: str) -> None:
        """Validate a Lua document"""
        if not uri.endswith(".lua"):
            return

        errors, warnings = self.validator.validate(text)
        
        # --- ADD THIS LINE BELOW ---
        self.publish_diagnostics(uri, errors, warnings) 
        # ---------------------------
        
        self._log(f"Diagnostics for {uri}: {len(errors)} errors, {len(warnings)} warnings")

    def completion(self, params: Dict[str, Any]) -> Dict[str, List[Dict]]:
        """Provide autocompletion suggestions"""
        completions: List[Dict[str, Any]] = []

        # 1) API database (v1.0.4 official)
        funcs = self.api_db.get("functions", []) if isinstance(self.api_db, dict) else []
        callbacks = self.api_db.get("callbacks", []) if isinstance(self.api_db, dict) else []

        for f in funcs:
            name = f.get("name")
            args = f.get("args", []) or []
            if not name:
                continue
            # Build snippet with placeholders for args
            placeholders = []
            for i in range(len(args)):
                placeholders.append(f"${i + 1}")
            insert = f"{name}({', '.join(placeholders)})"
            detail_args = ", ".join(args) if isinstance(args, list) else ""
            completions.append(
                {
                    "label": name,
                    "kind": 3,
                    "detail": f"{name}({detail_args})",
                    "insertText": insert,
                }
            )

        for cb in callbacks:
            name = cb.get("name")
            args = cb.get("args", []) or []
            if not name:
                continue
            detail_args = ", ".join(args) if isinstance(args, list) else ""
            completions.append(
                {
                    "label": name,
                    "kind": 3,
                    "detail": f"callback {name}({detail_args})",
                    "insertText": name,
                }
            )

        # 2) Legacy validator dictionaries (still useful globals)
        for func_name, spec in getattr(self.validator, "PSYCH_FUNCTIONS", {}).items():
            params_str = ", ".join(spec.get("params", []))
            completions.append(
                {
                    "label": func_name,
                    "kind": 3,
                    "detail": f"{func_name}({params_str})",
                    "insertText": f"{func_name}($0)",
                }
            )

        for var_name, var_type in getattr(self.validator, "PSYCH_GLOBALS", {}).items():
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
        return {"contents": "Psych Engine API (v1.0.4) supported by PsychIDE."}



    def handle_request(self, method: str, params: Dict[str, Any]) -> Any:
        """Handle an RPC request"""
        handler = self.methods.get(method)
        if handler:
            return handler(params)
        return None


    def get_semantic_tokens(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Provides syntax highlighting data to VS Code using delta encoding."""
        try:
            uri = params["textDocument"]["uri"]
            self._log(f"DEBUG: Starting token generation for {uri}")
            text = self.document_manager.get(uri, "")
            
            # 1. Pull BOTH functions and callbacks
            engine_funcs = [f.get("name") for f in self.api_db.get("functions", []) if f.get("name")]
            engine_callbacks = [c.get("name") for c in self.api_db.get("callbacks", []) if c.get("name")]
            all_engine_api = engine_funcs + engine_callbacks
            
            # 2. Regex
            engine_pattern = r'\b(' + '|'.join(all_engine_api) + r')(?=\s*\()' if all_engine_api else r'(?!x)x'
            patterns = [
                (r'\b(function|if|then|else|end|local|return|for|while|do)\b', 2),
                (r'"[^"]*"|\'[^\']*\'', 3),
                (engine_pattern, 6),
                (r'\b\d+(\.\d+)?\b', 4),
                (r'\b[a-zA-Z_]\w*\b', 0)
            ]

            # 3. Tokenize
            tokens = []
            for line_idx, line in enumerate(text.splitlines()):
                for pattern, type_idx in patterns:
                    for match in re.finditer(pattern, line):
                        tokens.append((line_idx, match.start(), match.end() - match.start(), type_idx))
            
            tokens.sort()
            
            # 4. Delta Encoding
            encoded_data = []
            prev_line, prev_char = 0, 0
            for line, char, length, type_idx in tokens:
                delta_line = line - prev_line
                delta_char = (char - prev_char) if delta_line == 0 else char
                encoded_data.extend([delta_line, delta_char, length, type_idx, 0])
                prev_line, prev_char = line, char
            
            self._log(f"DEBUG: Successfully sent {len(tokens)} tokens.")
            return {"data": encoded_data}

        except Exception as e:
            self._log(f"CRITICAL ERROR in get_semantic_tokens: {str(e)}")
            return {"data": []}


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

    try:
        logging.info("⚡ PsychIDE Python LSP Server is initializing...")

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
            except Exception:
                # Don't let hidden per-message exceptions kill the process
                logging.error("❌ LSP message handling failed")
                logging.error(traceback.format_exc())
                server._log({"error": "exception in message handler"})
    except Exception:
        logging.error("❌ FATAL SERVER CRASH OCCURRED")
        logging.error(traceback.format_exc())
        # Best-effort: still allow process exit gracefully




if __name__ == '__main__':
    main()
