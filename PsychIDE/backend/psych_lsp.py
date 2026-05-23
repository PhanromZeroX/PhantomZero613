"""
Psych Engine Language Server Protocol (LSP) implementation.
Provides autocompletion, diagnostics, and hover information for Psych modding.
"""

import json
import sys
from typing import Dict, Any, List
from pathlib import Path

from lua_validator import LuaValidator
from haxe_parser import HaxeParser


class PsychLanguageServer:
    def __init__(self):
        self.validator = LuaValidator()
        self.methods = {
            'initialize': self.initialize,
            'textDocument/didOpen': self.did_open,
            'textDocument/didChange': self.did_change,
            'textDocument/completion': self.completion,
            'textDocument/hover': self.hover,
        }
    
    def initialize(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Initialize the language server"""
        return {
            'capabilities': {
                'textDocumentSync': 2,  # Full document sync
                'completionProvider': {
                    'resolveProvider': True,
                    'triggerCharacters': ['.', '(', ' ']
                },
                'hoverProvider': True,
                'diagnosticProvider': True
            }
        }
    
    def did_open(self, params: Dict[str, Any]) -> None:
        """Handle document open"""
        uri = params['textDocument']['uri']
        text = params['textDocument']['text']
        self._validate_document(uri, text)
    
    def did_change(self, params: Dict[str, Any]) -> None:
        """Handle document changes"""
        uri = params['textDocument']['uri']
        # Get the updated text from contentChanges
        changes = params.get('contentChanges', [])
        if changes:
            text = changes[-1]['text']  # Last change
            self._validate_document(uri, text)
    
    def _validate_document(self, uri: str, text: str):
        """Validate a Lua document"""
        if not uri.endswith('.lua'):
            return
        
        errors, warnings = self.validator.validate(text)
        # In a real LSP, we'd send diagnostics to the client here
        print(f"Diagnostics for {uri}: {len(errors)} errors, {len(warnings)} warnings")
    
    def completion(self, params: Dict[str, Any]) -> Dict[str, List[Dict]]:
        """Provide autocompletion suggestions"""
        line = params['textDocument']['position']['line']
        char = params['textDocument']['position']['character']
        
        # Generate completion items from Psych API
        completions = []
        
        # Psych functions
        for func_name, spec in self.validator.PSYCH_FUNCTIONS.items():
            params_str = ', '.join(spec['params'])
            completions.append({
                'label': func_name,
                'kind': 3,  # Function
                'detail': f"{func_name}({params_str}): {spec['return']}",
                'insertText': f"{func_name}($0)"
            })
        
        # Psych globals
        for var_name, var_type in self.validator.PSYCH_GLOBALS.items():
            completions.append({
                'label': var_name,
                'kind': 25,  # Variable
                'detail': f"Global: {var_type}",
                'insertText': var_name
            })
        
        return {'isIncomplete': False, 'items': completions}
    
    def hover(self, params: Dict[str, Any]) -> Dict[str, str]:
        """Provide hover information"""
        # Extract symbol at cursor position
        # In a real implementation, we'd parse the AST
        return {
            'contents': 'Psych Engine API documentation available at docs/'
        }
    
    def handle_request(self, method: str, params: Dict[str, Any]) -> Any:
        """Handle an RPC request"""
        handler = self.methods.get(method)
        if handler:
            return handler(params)
        return None


def main():
    """Main LSP loop"""
    server = PsychLanguageServer()
    
    while True:
        # In a real LSP, we'd read from stdin and communicate via JSON-RPC
        # This is a simplified demo
        try:
            line = input()
            if line.startswith('Content-Length:'):
                # LSP header
                continue
            
            if line.strip():
                request = json.loads(line)
                method = request.get('method')
                params = request.get('params', {})
                
                result = server.handle_request(method, params)
                if result:
                    response = {
                        'jsonrpc': '2.0',
                        'id': request.get('id'),
                        'result': result
                    }
                    print(json.dumps(response))
        except EOFError:
            break
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)


if __name__ == '__main__':
    main()
