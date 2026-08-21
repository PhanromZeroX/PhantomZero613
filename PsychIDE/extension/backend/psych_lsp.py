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
import json as json_module
from datetime import datetime
import threading
from typing import Dict, Any, List, Optional

from lua_validator import LuaValidator
from ai_client import PsychAIClient


import pathlib
from lua_intelligence import LuaIntelligenceIndex
from project_rules import ProjectRules
from lua_api_loader import LuaApiLoader
from lua_scope import LuaScopeAnalyzer
from lua_structure import LuaStructureAnalyzer
from json_validator import JsonValidator
from haxe_parser import HaxeParser
from sprite_resizer import resize_sprite_sheet
from asset_health import scan_asset_folder
from project_detector import detect_project


class PsychLanguageServer:
    def __init__(self):
        self.validator = LuaValidator()
        self.index = LuaIntelligenceIndex()
        self.project_rules = ProjectRules()
        self.api_loader = LuaApiLoader()
        self.scope_analyzer = LuaScopeAnalyzer()
        self.structure_analyzer = LuaStructureAnalyzer()
        self.json_validator = JsonValidator()
        self.haxe_api: Dict[str, List[Dict[str, Any]]] = {"functions": [], "classes": []}
        self.ai_client = PsychAIClient()
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
        self.validator = LuaValidator(self.api_db)

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
            "textDocument/didClose": self.did_close,
            "workspace/executeCommand": self.execute_command,
            "textDocument/codeAction": self.code_action,
            "textDocument/completion": self.completion,
            "textDocument/signatureHelp": self.signature_help,
            "textDocument/hover": self.hover,
            "textDocument/semanticTokens/full": self.get_semantic_tokens,
            "textDocument/definition": self.definition,
            "textDocument/references": self.references,
            "textDocument/documentSymbol": self.document_symbols,
            "workspace/symbol": self.workspace_symbols,
            "textDocument/rename": self.rename,
            "psychIde/validateDocument": self.validate_document,
            "psychIde/configureAiKey": self.configure_ai_key,
            "psychIde/reindexWorkspace": self.reindex_workspace,
            "psychIde/resizeSpriteSheet": self.resize_sprite_sheet,
            "psychIde/scanAssetHealth": self.scan_asset_health,
            "psychIde/validateWorkspace": self.validate_workspace,
            "psychIde/projectSummary": self.project_summary,
            "psychIde/explainSymbol": self.explain_symbol,
            "psychIde/detectProject": self.detect_project,
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
                    "end": {"line": line, "character": col + max(err.get('length', 1), 1)}
                },
                "severity": 1, # 1 = Error
                "message": msg,
                "source": "PsychIDE",
                "code": err.get('code', 'psych-rule'),
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
                    "end": {"line": line, "character": col + max(warn.get('length', 1), 1)}
                },
                "severity": 2, # 2 = Warning
                "message": msg,
                "source": "PsychIDE",
                "code": warn.get('code', 'psych-rule'),
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

    def validate_document(self, params: Dict[str, Any]) -> Dict[str, Any]:
        uri = params["textDocument"]["uri"]
        text = params["textDocument"].get("text", self.document_manager.get(uri, ""))
        self.document_manager[uri] = text
        if uri.lower().endswith(".json"):
            errors, warnings = self._validate_json_text(uri, text)
            self.last_diagnostics[uri] = (errors, warnings)
            self.publish_diagnostics(uri, errors, warnings)
            return {"errors": errors, "warnings": warnings}
        self.index.update(uri, text)
        errors, warnings = self._validate_text(text)
        self.last_diagnostics[uri] = (errors, warnings)
        self.publish_diagnostics(uri, errors, warnings)
        return {"errors": errors, "warnings": warnings}

    def configure_ai_key(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Configure the AI key in memory for this server process only."""
        api_key = params.get("apiKey", "")
        if not isinstance(api_key, str):
            return {"ok": False, "error": "The API key must be text."}
        if api_key:
            self.ai_client.set_api_key(api_key)
            return {"ok": True, "configured": True}
        self.ai_client.clear_api_key()
        return {"ok": True, "configured": False}


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
        self.index.set_workspace(root_uri)
        self.project_rules.set_workspace(self.index.workspace_root)
        self.json_validator.set_workspace(self.index.workspace_root)
        self._load_workspace_api()
        self._load_haxe_api()
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
                "signatureHelpProvider": {
                    "triggerCharacters": ["(", ","],
                    "retriggerCharacters": [","],
                },
                "hoverProvider": True,
                "definitionProvider": True,
                "referencesProvider": True,
                "documentSymbolProvider": True,
                "workspaceSymbolProvider": True,
                "renameProvider": True,
                "codeActionProvider": True,
                "diagnosticProvider": True,
                "semanticTokensProvider": {
                    "legend": {
                        "tokenTypes": ["variable", "function", "keyword", "string", "number", "type", "engine"],
                        "tokenModifiers": [],
                    },
                    "full": True,
                    "range": True,
                },
                "hoverProvider": True
            }
        }

    def _load_workspace_api(self) -> None:
        if not self.index.workspace_root:
            return
        discovered = self.api_loader.load_workspace_api(self.index.workspace_root)
        for category in ("functions", "callbacks"):
            existing = {item.get("name"): item for item in self.api_db.get(category, [])}
            for item in discovered.get(category, []):
                if item.get("name") in existing:
                    existing[item["name"]].update(item)
                else:
                    self.api_db.setdefault(category, []).append(item)
        self.validator = LuaValidator(self.api_db)

    def _load_haxe_api(self) -> None:
        if not self.index.workspace_root:
            self.haxe_api = {"functions": [], "classes": []}
            return
        self.haxe_api = HaxeParser(str(self.index.workspace_root)).extract_all_apis()

    def code_action(self, params: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Provides smart, context-aware code actions based on the word under the cursor."""
        uri = params["textDocument"]["uri"]
        pos = params["range"]["start"]
        line_idx = pos["line"]
        char_idx = pos["character"]
        
        # 1. Get the word under the cursor to provide relevant actions
        text = self.document_manager.get(uri, "")
        lines = text.splitlines()
        if line_idx < len(lines):
            word = self._get_word_at_position(lines[line_idx], char_idx)
        else:
            word = None

        actions = []

        for diagnostic in params.get("context", {}).get("diagnostics", []):
            code = diagnostic.get("code")
            if code == "psych-shader-name" and line_idx < len(lines):
                current_line = lines[line_idx]
                match = re.search(r"(['\"])([^'\"]+)(\.(?:frag|vsh))\1", current_line)
                if match:
                    actions.append({
                        "title": "Remove shader file extension",
                        "kind": "quickfix",
                        "diagnostics": [diagnostic],
                        "edit": {"changes": {uri: [{
                            "range": {
                                "start": {"line": line_idx, "character": match.start(2)},
                                "end": {"line": line_idx, "character": match.end(2) + len(match.group(3))},
                            },
                            "newText": match.group(2),
                        }]}},
                    })
        
        # 2. Add action only if we're hovering over a known Psych function
        if word and any(f.get("name") == word for f in self.api_db.get("functions", [])):
            actions.append({
                "title": f"🎨 [Psych] Generate '{word}' boilerplate",
                "kind": "quickfix",
                "command": {
                    "title": "Generate Boilerplate",
                    "command": "psychIde.generateSnippet",
                    "arguments": [uri, pos, word] # Pass the word so the extension knows what to generate!
                }
            })
            
        return actions

    def initialized(self, _params: Dict[str, Any]) -> None:
        # Handshake completion handler (empty by design)
        return None

    def did_open(self, params: Dict[str, Any]) -> None:
        """Handle document open"""
        uri = params["textDocument"]["uri"]
        text = params["textDocument"]["text"]
        
        # Add this line to ensure the document manager knows the file content
        self.document_manager[uri] = text 
        self.index.update(uri, text)
        
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
        text = self.document_manager.get(uri, "")
        for change in params.get("contentChanges", []):
            if "range" not in change:
                text = change.get("text", "")
            else:
                text = self._apply_text_change(text, change)
        self.document_manager[uri] = text
        self.index.update(uri, text)
        
        # Trigger the debounced validation
        self.on_did_change(params)

    def did_save(self, params: Dict[str, Any]) -> None:
        """Handle document save - force run immediate evaluation to counter Client Wipes"""
        if self.debounce_timer:
            self.debounce_timer.cancel()
        
        self.validate_and_publish(params)

    def did_close(self, params: Dict[str, Any]) -> None:
        uri = params["textDocument"]["uri"]
        self.document_manager.pop(uri, None)
        self.last_diagnostics.pop(uri, None)
        self.index.remove(uri)
        self.publish_diagnostics(uri, [], [])

    def reindex_workspace(self, _params: Dict[str, Any]) -> Dict[str, Any]:
        self.index.rebuild()
        self._load_workspace_api()
        self._load_haxe_api()
        return {
            "ok": True,
            "documents": len(self.index.documents),
            "symbols": sum(len(values) for values in self.index.symbols.values()),
            "apiFunctions": len(self.validator.functions),
            "apiCallbacks": len(self.validator.callbacks),
            "haxeFunctions": len(self.haxe_api.get("functions", [])),
            "haxeClasses": len(self.haxe_api.get("classes", [])),
        }

    def resize_sprite_sheet(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Resize a sprite sheet PNG and update sidecar metadata.

        Example payload:
        {
            "imagePath": "/path/to/sheet.png",
            "targetWidth": 2048,
            "xmlPath": "/path/to/sheet.xml",
            "jsonPaths": ["/path/to/sheet.json"],
            "overwrite": false
        }
        """
        image_path = params.get("imagePath")
        if not image_path:
            return {"ok": False, "error": "imagePath is required"}

        try:
            result = resize_sprite_sheet(
                image_path,
                target_width=int(params.get("targetWidth", 2048)),
                xml_path=params.get("xmlPath"),
                json_paths=params.get("jsonPaths") or [],
                overwrite=bool(params.get("overwrite", False)),
                output_image_path=params.get("outputImagePath"),
                output_xml_path=params.get("outputXmlPath"),
                output_json_paths=params.get("outputJsonPaths"),
            )
            return result
        except Exception as exc:  # pragma: no cover - defensive server behavior
            return {"ok": False, "error": str(exc)}

    def scan_asset_health(self, params: Dict[str, Any]) -> Dict[str, Any]:
        folder_path = params.get("folderPath")
        if not folder_path:
            return {"ok": False, "error": "folderPath is required"}
        return scan_asset_folder(
            folder_path,
            profile=str(params.get("profile", "balanced")),
            max_dimension=params.get("maxDimension"),
        )

    def validate_workspace(self, _params: Dict[str, Any]) -> Dict[str, Any]:
        """Validate every indexed Lua and JSON document without changing files."""
        self.index.rebuild()
        results = []
        totals = {"files": 0, "errors": 0, "warnings": 0}
        for uri, text in sorted(self.index.documents.items()):
            if uri.lower().endswith(".json"):
                errors, warnings = self._validate_json_text(uri, text)
            else:
                errors, warnings = self._validate_text(text)
            totals["files"] += 1
            totals["errors"] += len(errors)
            totals["warnings"] += len(warnings)
            if errors or warnings:
                results.append({"uri": uri, "errors": errors, "warnings": warnings})
        return {"ok": True, "totals": totals, "results": results}

    def project_summary(self, params: Dict[str, Any]) -> Dict[str, Any]:
        folder_path = params.get("folderPath") or (str(self.index.workspace_root) if self.index.workspace_root else "")
        if not folder_path:
            return {"ok": False, "error": "No workspace folder is available"}
        validation = self.validate_workspace({})
        assets = scan_asset_folder(folder_path, profile=str(params.get("profile", "balanced")))
        root = pathlib.Path(folder_path)
        files = {"lua": 0, "haxe": 0, "json": 0, "png": 0}
        for file_path in root.rglob("*"):
            if not file_path.is_file() or any(part in {".git", "node_modules", "out", "build", "dist", "psychide-resized"} for part in file_path.parts):
                continue
            suffix = file_path.suffix.lower()
            if suffix == ".lua": files["lua"] += 1
            elif suffix == ".hx": files["haxe"] += 1
            elif suffix == ".json": files["json"] += 1
            elif suffix == ".png": files["png"] += 1
        return {
            "ok": True,
            "folder": folder_path,
            "files": files,
            "validation": validation.get("totals", {}),
            "assets": assets.get("totals", {}),
            "api": {
                "functions": len(self.validator.functions),
                "callbacks": len(self.validator.callbacks),
                "haxeFunctions": len(self.haxe_api.get("functions", [])),
                "haxeClasses": len(self.haxe_api.get("classes", [])),
            },
            "project": detect_project(folder_path),
        }

    def detect_project(self, params: Dict[str, Any]) -> Dict[str, Any]:
        folder_path = params.get("folderPath") or (str(self.index.workspace_root) if self.index.workspace_root else "")
        if not folder_path:
            return {"ok": False, "error": "No folder supplied"}
        return detect_project(folder_path)

    def explain_symbol(self, params: Dict[str, Any]) -> Dict[str, Any]:
        name = str(params.get("name", ""))
        for category in ("functions", "callbacks"):
            for item in self.api_db.get(category, []):
                if item.get("name") == name:
                    return {"ok": True, "name": name, "kind": category[:-1], **item}
        return {"ok": False, "error": f"No Psych Engine guide found for {name}"}

    def validate_and_publish(self, params):
        uri = params["textDocument"]["uri"]
        text = self.document_manager.get(uri, "")
        if uri.lower().endswith(".json"):
            errors, warnings = self._validate_json_text(uri, text)
            self.last_diagnostics[uri] = (errors, warnings)
            self.publish_diagnostics(uri, errors, warnings)
            return
        
        # 1. Run the validator scan on the full, uncorrupted text
        errors, warnings = self._validate_text(text)
        
        # 2. Update the cache and push the real updates directly to VS Code
        self.last_diagnostics[uri] = (errors, warnings)
        self.publish_diagnostics(uri, errors, warnings)

    def _validate_document(self, uri: str, text: str) -> None:
        """Validate a Lua document"""
        if uri.lower().endswith(".json"):
            errors, warnings = self._validate_json_text(uri, text)
            self.last_diagnostics[uri] = (errors, warnings)
            self.publish_diagnostics(uri, errors, warnings)
            return
        if not uri.endswith(".lua"):
            return

        errors, warnings = self._validate_text(text)
        
        # --- ADD THIS LINE BELOW ---
        self.publish_diagnostics(uri, errors, warnings) 
        # ---------------------------
        
        self._log(f"Diagnostics for {uri}: {len(errors)} errors, {len(warnings)} warnings")

    def _validate_json_text(self, uri: str, text: str):
        return self.json_validator.validate(uri, text)

    def _validate_text(self, text: str):
        errors, warnings = self.validator.validate(text)
        rule_errors, rule_warnings = self.project_rules.validate("", text)
        structure_errors, structure_warnings = self.structure_analyzer.analyze(text)
        scope_errors, scope_warnings = self.scope_analyzer.analyze(
            text,
            set(self.validator.functions) | set(self.validator.callbacks) | set(self.validator.PSYCH_GLOBALS),
        )
        errors.extend(rule_errors)
        errors.extend(structure_errors)
        warnings.extend(rule_warnings)
        warnings.extend(structure_warnings)
        warnings.extend(scope_warnings)
        known_project_names = set(self.index.symbols)
        warnings = [
            warning for warning in warnings
            if not (
                warning.get("message", "").startswith("Unknown function: ")
                and warning["message"].split(": ", 1)[1] in known_project_names
            )
        ]
        return errors, warnings

    def _apply_text_change(self, text: str, change: Dict[str, Any]) -> str:
        """Apply an incremental LSP edit to the cached document."""
        change_range = change["range"]
        lines = text.splitlines(keepends=True)
        start = change_range["start"]
        end = change_range["end"]
        if start["line"] >= len(lines) or end["line"] >= len(lines):
            return change.get("text", text)
        start_offset = sum(len(line) for line in lines[:start["line"]]) + start["character"]
        end_offset = sum(len(line) for line in lines[:end["line"]]) + end["character"]
        return text[:start_offset] + change.get("text", "") + text[end_offset:]

    def completion(self, params: Dict[str, Any]) -> Dict[str, List[Dict]]:
        """Provide autocompletion suggestions"""
        completions: List[Dict[str, Any]] = []

        uri = params["textDocument"]["uri"]
        position = params.get("position", {})
        line = self.document_manager.get(uri, "").splitlines()
        current_line = line[position.get("line", 0)] if position.get("line", 0) < len(line) else ""
        prefix = re.search(r"[A-Za-z_][A-Za-z0-9_]*$", current_line[:position.get("character", 0)])
        name_prefix = prefix.group(0) if prefix else ""

        # 1) Project symbols, filtered to the user's current prefix.
        for name in self.index.names(name_prefix):
            symbol = self.index.definitions(name)[0]
            completions.append({
                "label": name,
                "kind": symbol.kind,
                "detail": f"{symbol.detail} (project)",
                "insertText": name,
            })

        # 2) API database (v1.0.4 official)
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
        for func_name, spec in getattr(self.validator, "functions", {}).items():
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

    def signature_help(self, params: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        uri = params["textDocument"]["uri"]
        position = params.get("position", {})
        line_number = position.get("line", 0)
        character = position.get("character", 0)
        lines = self.document_manager.get(uri, "").splitlines()
        if line_number >= len(lines):
            return None

        before_cursor = "\n".join(lines[:line_number] + [lines[line_number][:character]])
        call = self._active_call(before_cursor)
        if not call:
            return None
        function_name, argument_index = call
        spec = self.validator.functions.get(function_name) or self.validator.callbacks.get(function_name)
        if not spec:
            return None
        params_spec = spec.get("args", [])
        labels = []
        for item in params_spec:
            if isinstance(item, dict):
                labels.append({
                    "label": f"{item.get('name', 'arg')}: {item.get('type', 'any')}",
                    "documentation": item.get("description", ""),
                })
            else:
                labels.append(str(item))
        return {
            "signatures": [{
                "label": f"{function_name}({', '.join(self._parameter_labels(params_spec))})",
                "documentation": spec.get("description", "Psych Engine v1.0.4 API"),
                "parameters": labels,
            }],
            "activeSignature": 0,
            "activeParameter": min(argument_index, max(len(labels) - 1, 0)),
        }

    def _parameter_labels(self, params: List[Any]) -> List[str]:
        labels = []
        for item in params:
            if isinstance(item, dict):
                labels.append(f"{item.get('name', 'arg')}: {item.get('type', 'any')}")
            else:
                labels.append(str(item))
        return labels

    def _active_call(self, text: str) -> Optional[tuple]:
        depth = 0
        quote = None
        argument_index = 0
        open_index = -1
        for index in range(len(text) - 1, -1, -1):
            char = text[index]
            if quote:
                if char == quote and (index == 0 or text[index - 1] != "\\"):
                    quote = None
                continue
            if char in "'\"":
                quote = char
            elif char == ')':
                depth += 1
            elif char == '(':
                if depth:
                    depth -= 1
                else:
                    open_index = index
                    break
            elif char == ',' and depth == 0:
                argument_index += 1
        if open_index < 0:
            return None
        prefix = text[:open_index].rstrip()
        match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)$", prefix)
        return (match.group(1), argument_index) if match else None

    def _symbol_location(self, symbol: Any) -> Dict[str, Any]:
        return {
            "uri": symbol.uri,
            "range": {
                "start": {"line": symbol.line, "character": symbol.character},
                "end": {"line": symbol.line, "character": symbol.character + len(symbol.name)},
            },
        }

    def _requested_word(self, params: Dict[str, Any]) -> Optional[str]:
        uri = params["textDocument"]["uri"]
        position = params.get("position", params.get("range", {}).get("start", {}))
        return self.index.word_at(uri, position.get("line", 0), position.get("character", 0))

    def definition(self, params: Dict[str, Any]) -> List[Dict[str, Any]]:
        word = self._requested_word(params)
        return [self._symbol_location(symbol) for symbol in self.index.definitions(word)] if word else []

    def references(self, params: Dict[str, Any]) -> List[Dict[str, Any]]:
        word = self._requested_word(params)
        if not word:
            return []
        locations = self.index.references_for(word) + self.index.definitions(word)
        return [self._symbol_location(symbol) for symbol in locations]

    def document_symbols(self, params: Dict[str, Any]) -> List[Dict[str, Any]]:
        uri = params["textDocument"]["uri"]
        return [{
            "name": symbol.name,
            "kind": symbol.kind,
            "detail": symbol.detail,
            "range": self._symbol_location(symbol)["range"],
            "selectionRange": self._symbol_location(symbol)["range"],
        } for symbol in self.index.symbols_for_uri(uri)]

    def workspace_symbols(self, params: Dict[str, Any]) -> List[Dict[str, Any]]:
        query = params.get("query", "").lower()
        results = []
        for name in self.index.names():
            if query and query not in name.lower():
                continue
            for symbol in self.index.definitions(name):
                results.append({"name": name, "kind": symbol.kind, "location": self._symbol_location(symbol)})
        for function in self.haxe_api.get("functions", []):
            name = function.get("name", "")
            if name and (not query or query in name.lower()):
                results.append({"name": name, "kind": 6, "location": {"uri": function.get("file", "")}})
        for class_info in self.haxe_api.get("classes", []):
            name = class_info.get("name", "")
            if name and (not query or query in name.lower()):
                results.append({"name": name, "kind": 5, "location": {"uri": class_info.get("file", "")}})
        return results

    def rename(self, params: Dict[str, Any]) -> Dict[str, List[Dict[str, Any]]]:
        old_name = self._requested_word(params)
        new_name = params.get("newName", "")
        if not old_name or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", new_name):
            return {"changes": {}}
        changes: Dict[str, List[Dict[str, Any]]] = {}
        for symbol in self.index.references_for(old_name) + self.index.definitions(old_name):
            changes.setdefault(symbol.uri, []).append({
                "range": self._symbol_location(symbol)["range"],
                "newText": new_name,
            })
        return {"changes": changes}


    def hover(self, params: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Provides premium, highly detailed markdown documentation tooltips on hover."""
        try:
            uri = params["textDocument"]["uri"]
            pos = params["position"]
            line_idx = pos["line"]
            char_idx = pos["character"]

            text = self.document_manager.get(uri, "")
            lines = text.splitlines()
            if line_idx >= len(lines):
                return None

            line = lines[line_idx]
            word = self._get_word_at_position(line, char_idx)
            if not word:
                return None

            # 🛠️ 1. Search official engine functions
            for f in self.api_db.get("functions", []):
                if f.get("name") == word:
                    # Extract rich metadata
                    args_info = f.get("args", []) # Expecting format: [{"name": "alpha", "type": "float"}]
                    desc = f.get("description", "No description available.")
                    
                    # Create formatted param strings with types if available
                    params_list = []
                    for arg in args_info:
                        if isinstance(arg, dict):
                            params_list.append(f"`({arg.get('type', 'any')}) {arg.get('name')}`")
                        else:
                            params_list.append(f"`{arg}`")
                    
                    args_str = ", ".join(params_list)
                    beginner = f.get("beginner", "")
                    example = f.get("example", "")
                    tips = f.get("tips", [])
                    tips_markdown = "\n".join(f"* {tip}" for tip in tips)
                    example_text = example or f"{word}({', '.join('...' for _ in args_info)})"
                    
                    markdown = (
                        f"### 💡 `{word}(...)`\n"
                        f"---\n"
                        f"✨ **Psych Engine v1.0.4** • *API Function*\n\n"
                        f"{desc}\n\n"
                        f"**Beginner guide:** {beginner}\n\n" if beginner else ""
                    ) + (
                        f"* **Parameters:** {args_str if args_str else '`None`'}\n"
                        f"* **Returns:** `{f.get('return', 'void')}`\n\n"
                        f"**Example:**\n```lua\n{example_text}\n```\n\n"
                        f"**Tips:**\n{tips_markdown or '* Check the Psych Engine API documentation for details.'}"
                    )
                    return {"contents": {"kind": "markdown", "value": markdown}}

            # Callback guidance uses the same beginner-oriented API metadata.
            for callback in self.api_db.get("callbacks", []):
                if callback.get("name") != word:
                    continue
                args = callback.get("args", [])
                labels = ", ".join(str(arg.get("name", "arg")) if isinstance(arg, dict) else str(arg) for arg in args)
                tips = callback.get("tips", [])
                tips_markdown = "\n".join(f"* {tip}" for tip in tips)
                example_text = callback.get("example", f"function {word}({labels})\nend")
                markdown = (
                    f"### 💡 `{word}({labels})`\n---\n"
                    f"✨ **Psych Engine callback**\n\n"
                    f"{callback.get('description', 'Engine callback.')}\n\n"
                    f"**Beginner guide:** {callback.get('beginner', 'Use this callback to react to an engine event.')}\n\n"
                    f"**Example:**\n```lua\n{example_text}\n```\n\n"
                    f"**Tips:**\n{tips_markdown or '* Keep callback work short and focused.'}"
                )
                return {"contents": {"kind": "markdown", "value": markdown}}

            # 🛠️ 2. Fallback to validator
            if word in self.validator.functions:
                spec = self.validator.functions[word]
                params_list = [f"`{p}`" for p in spec.get('params', [])]
                
                markdown = (
                    f"### 💡 `{word}({', '.join(spec.get('params', []))})`\n"
                    f"---\n"
                    f"🔧 **Psych Engine Standard API**\n\n"
                    f"* **Parameters:** {', '.join(params_list) if params_list else '`None`'}\n"
                    f"* **Returns:** `{spec.get('return', 'void')}`\n\n"
                    f"```lua\n"
                    f"{word}({', '.join(['...' for _ in spec.get('params', [])])})\n"
                    f"```"
                )
                return {"contents": {"kind": "markdown", "value": markdown}}

            return None

        except Exception as e:
            self._log(f"CRITICAL ERROR in hover provider: {str(e)}")
        return None
            



    def handle_request(self, method: str, params: Dict[str, Any]) -> Any:
        """Handle an RPC request"""
        handler = self.methods.get(method)
        if handler:
            return handler(params)
        return None

    def _get_word_at_position(self, line: str, client_char: int) -> str:
        """Helper to extract the full word under the user's cursor mouse coordinates"""
        # Find all words/tokens in the current line, now including underscore support
        # This regex ensures we catch things like 'getProperty' or 'my_variable' perfectly
        for match in re.finditer(r'\b[a-zA-Z_]\w*\b', line):
            if match.start() <= client_char <= match.end():
                return match.group(0)
        return ""


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
        
    def execute_command(self, params: Dict[str, Any]) -> Any:
        """Handles the AI fix command coming from VS Code."""
        command = params.get("command")
        args = params.get("arguments", [])
        
        if command == "psychIde.askAiToFix":
            # 1. args[0] is the URI, args[1] is the line number
            # 2. Let's make sure we safely pass the actual code and error message
            uri = args[0]
            line_idx = args[1]
            
            # Fetch the actual text from the document manager
            code_lines = self.document_manager.get(uri, "").splitlines()
            line_code = code_lines[line_idx] if line_idx < len(code_lines) else ""
            
            # Get the error message for this line (if any)
            error_msg = "Unknown error"
            for err in self.validator.errors:
                if err['line'] == line_idx + 1:
                    error_msg = err['message']
            
            # Call the AI client
            fixed_response = self.ai_client.ask_ai_to_fix(error_msg, line_code)
            if fixed_response.get("error"):
                return fixed_response
            proposed_code = fixed_response.get("fixed_code", "")
            proposed_errors, _ = self._validate_text(proposed_code)
            if proposed_errors:
                return {
                    "error": "AI proposed code that still violates PsychIDE rules.",
                    "validation_errors": proposed_errors,
                }
            
            return fixed_response
            
        return {"error": "Unknown command"}

    def ask_ai_to_fix(self, uri: str, line_idx: int) -> Dict[str, Any]:
        """Queries the PsychAIClient for a fix and returns the payload."""
        text = self.document_manager.get(uri, "")
        lines = text.splitlines()
        
        if line_idx < 0 or line_idx >= len(lines):
            return {"error": "Invalid line index"}
        
        line_code = lines[line_idx]
        
        # Get existing diagnostics to help the AI understand the error
        error_msg = "Unknown error"
        if uri in self.last_diagnostics:
            errors, warnings = self.last_diagnostics[uri]
            for diag in errors + warnings:
                if diag.get('line', 0) - 1 == line_idx:
                    error_msg = diag['message']
        
        # Ask our AI Brain (ai_client.py)
        response = self.ai_client.ask_ai_to_fix(error_msg, line_code)
        if response.get("error"):
            return response
        fixed_code = response.get("fixed_code", "")
        validation_errors, _ = self._validate_text(fixed_code)
        if validation_errors:
            return {
                "error": "AI proposed code that still violates PsychIDE rules.",
                "validation_errors": validation_errors,
            }
        
        return {
            "fixed_code": fixed_code,
            "line": line_idx
        }


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
