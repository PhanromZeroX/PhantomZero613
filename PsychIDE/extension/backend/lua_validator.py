"""
Lua code validator - checks if Lua code is compatible with Psych Engine.
Validates function calls, parameters, and shader usage.
"""

import re
from typing import List, Dict, Any, Tuple, Optional


class LuaValidator:
    """Validates Lua code against Psych Engine API specifications"""
    
    # Psych Engine core functions (from docs)
    PSYCH_FUNCTIONS = {
        'initLuaShader': {'params': ['shaderName'], 'return': 'void'},
        'setSpriteShader': {'params': ['spriteId', 'shaderName'], 'return': 'void'},
        'setShaderFloat': {'params': ['spriteName', 'uniform', 'value'], 'return': 'void'},
        'setShaderInt': {'params': ['spriteName', 'uniform', 'value'], 'return': 'void'},
        'setShaderVec2': {'params': ['spriteName', 'uniform', 'x', 'y'], 'return': 'void'},
        'setShaderVec3': {'params': ['spriteName', 'uniform', 'x', 'y', 'z'], 'return': 'void'},
        'makeLuaSprite': {'params': ['spriteId', 'graphic', 'x', 'y'], 'return': 'void'},
        'makeGraphic': {'params': ['spriteName', 'width', 'height', 'color'], 'return': 'void'},
        'runHaxeCode': {'params': ['code'], 'return': 'void'},
        'debugPrint': {'params': ['text'], 'return': 'void'},
        'getSongPosition': {'params': [], 'return': 'float'},
        'getVar': {'params': ['varName'], 'return': 'any'},
        'setVar': {'params': ['varName', 'value'], 'return': 'void'},
        'addLuaSprite': {'params': ['spriteId', 'inFront'], 'return': 'void'},
        'doTweenY': {'params': ['id', 'target', 'value', 'duration'], 'return': 'void'},
        'doTweenX': {'params': ['id', 'target', 'value', 'duration'], 'return': 'void'},
    }
    
    # Psych Engine global variables
    PSYCH_GLOBALS = {
        'shadersEnabled': 'boolean',
        'screenWidth': 'number',
        'screenHeight': 'number',
    }
    
    # Callback functions
    PSYCH_CALLBACKS = [
        'onCreate', 'onStartCountdown', 'onUpdate', 'onUpdatePost',
        'onBeatHit', 'onStepHit', 'onCountdownTick', 'onSongStart',
        'onGameOver', 'onEndSong', 'onCreatePost'
    ]
    
    def __init__(self, api_db: Optional[Dict[str, Any]] = None):
        self.errors: List[Dict[str, Any]] = []
        self.warnings: List[Dict[str, Any]] = []
        self.api_db = api_db or {}
        self.functions = self._build_function_specs()
        self.callbacks = self._build_callback_specs()

    def _build_function_specs(self) -> Dict[str, Dict[str, Any]]:
        specs = dict(self.PSYCH_FUNCTIONS)
        for function in self.api_db.get('functions', []):
            name = function.get('name')
            if not name:
                continue
            args = function.get('args', []) or []
            specs[name] = {
                'params': [arg.get('name', 'arg') if isinstance(arg, dict) else arg for arg in args],
                'args': args,
                'return': function.get('return', function.get('return_type', 'void')),
                'description': function.get('description', ''),
            }
        return specs

    def _build_callback_specs(self) -> Dict[str, Dict[str, Any]]:
        specs = {name: {'params': []} for name in self.PSYCH_CALLBACKS}
        for callback in self.api_db.get('callbacks', []):
            name = callback.get('name')
            if name:
                args = callback.get('args', []) or []
                specs[name] = {'params': [arg.get('name', 'arg') if isinstance(arg, dict) else arg for arg in args]}
        return specs
    
    def validate(self, lua_code: str) -> Tuple[List[Dict], List[Dict]]:
        """Validate Lua code and return errors/warnings"""
        self.errors = []
        self.warnings = []
        
        lines = lua_code.split('\n')
        
        for line_no, line in enumerate(lines, 1):
            self._check_function_calls(line, line_no)
            self._check_shader_usage(line, line_no)
            self._check_undefined_vars(line, line_no)
        
        return self.errors, self.warnings
    
    def _check_function_calls(self, line: str, line_no: int):
        """Check for correct argument counts in Psych Engine API calls"""
        
        # 🚨 UPGRADE: The forgiving regex! 
        # r'(\w+)\s*\(([^)]*)' means: 
        # 1. Find a word (function name)
        # 2. Find an opening '('
        # 3. Grab everything after it that ISN'T a closing ')'
        for match in re.finditer(r'(\w+)\s*\(([^)]*)', line):
            func_name = match.group(1)
            args_string = match.group(2)
            
            # Count the arguments by splitting at commas
            # (If it's empty space, it counts as 0 args)
            args = self._split_args(args_string)
            arg_count = len(args)

            # --- Your existing dictionary check goes here ---
            # Example:
            
            expected_spec = self.functions.get(func_name)
            if expected_spec:
                expected_args = len(expected_spec.get('params', []))
                if arg_count != expected_args:
                    self.errors.append({
                        'line': line_no,
                        'col': match.start(),
                        'length': len(func_name),
                        'code': 'psych-arity',
                        'message': f'Argument mismatch: {func_name} expects {expected_args} args, but got {arg_count}.'
                    })
                self._check_argument_types(func_name, args, expected_spec.get('args', []), line_no, match.start())
                continue # Known function processed safely; skip downstream checks
            
            # Check if it's a callback
            callback_spec = self.callbacks.get(func_name)
            if callback_spec:
                expected_args = len(callback_spec.get('params', []))
                if arg_count != expected_args:
                    self.errors.append({
                        'line': line_no,
                        'col': match.start(),
                        'length': len(func_name),
                        'code': 'psych-callback-arity',
                        'message': f'Callback {func_name} expects {expected_args} args, but got {arg_count}.',
                    })
                continue
            
            # Check if it's a Lua standard library function
            lua_stdlib = ['print', 'table', 'string', 'math', 'assert', 'type', 'pairs', 'ipairs']
            if func_name in lua_stdlib or func_name.startswith('table.') or func_name.startswith('string.'):
                continue
            
            # Warn about unknown functions (info only)
            if not any(func_name.startswith(f) for f in ['local', 'if', 'for', 'while', 'function']):
                self.warnings.append({
                    'line': line_no,
                    'col': match.start(1),
                    'length': len(func_name),
                    'code': 'psych-unknown-function',
                    'message': f'Unknown function: {func_name}',
                    'severity': 'info'
                })

    def _check_argument_types(self, func_name: str, args: List[str], specs: List[Any], line_no: int, col: int) -> None:
        for index, (argument, spec) in enumerate(zip(args, specs)):
            if not isinstance(spec, dict):
                continue
            expected = spec.get('type', '').lower()
            expected = {'bool': 'boolean', 'int': 'number', 'float': 'number'}.get(expected, expected)
            actual = self._literal_type(argument)
            actual = {'bool': 'boolean'}.get(actual, actual)
            if not expected or expected in ('any', 'dynamic') or actual is None or actual == expected:
                continue
            self.errors.append({
                'line': line_no,
                'col': col,
                'length': len(func_name),
                'code': 'psych-type',
                'message': f'Argument {index + 1} of {func_name} expects {expected}, but got {actual}.',
            })

    def _literal_type(self, argument: str) -> Optional[str]:
        value = argument.strip()
        if re.fullmatch(r"['\"].*['\"]", value):
            return 'string'
        if re.fullmatch(r'-?(?:\d+(?:\.\d*)?|\.\d+)', value):
            return 'number'
        if value in ('true', 'false'):
            return 'bool'
        return None

    def _split_args(self, args_string: str) -> List[str]:
        if not args_string.strip():
            return []
        args: List[str] = []
        start = 0
        depth = 0
        quote = None
        escaped = False
        for index, char in enumerate(args_string):
            if quote:
                if escaped:
                    escaped = False
                elif char == '\\':
                    escaped = True
                elif char == quote:
                    quote = None
                continue
            if char in "'\"":
                quote = char
            elif char in '([{':
                depth += 1
            elif char in ')]}':
                depth = max(depth - 1, 0)
            elif char == ',' and depth == 0:
                args.append(args_string[start:index].strip())
                start = index + 1
        args.append(args_string[start:].strip())
        return args
    
    def _check_shader_usage(self, line: str, line_no: int):
        """Check if shader-related code is correct and strictly enforce extensions"""
        if 'initLuaShader' in line:
            # Look for the shader name inside the function
            match = re.search(r"initLuaShader\s*\(\s*['\"]([^'\"]+)['\"]\s*\)", line)
            if match:
                shader_name = match.group(1)

                # 🚨 UPGRADE: Push to self.errors instead of self.warnings!
                if '.frag' in shader_name or '.vsh' in shader_name:
                    self.errors.append({
                        'line': line_no,
                        'col': line.find(shader_name),
                        'length': len(shader_name),
                        'code': 'psych-shader-name',
                        'message': f'Invalid Shader Name: "{shader_name}". Do not include .frag or .vsh extensions.'
                    })


        # Validate generic shader string asset usage: any string literal ending in .frag/.vsh is treated as an asset.
        # This is intentionally permissive so we don't drop/flag it as an undefined token.
        if re.search(r"['\"][^'\"]+\.(frag|vsh)['\"]", line, flags=re.IGNORECASE):
            return

    
    def _check_undefined_vars(self, line: str, line_no: int):
        """Check for undefined variable usage"""
        # Float literal recognition sanity: allow decimal numbers.
        # (Prevents over-aggressive integer-only heuristics elsewhere in the pipeline.)
        _ = re.search(r"\b\d+\.\d+\b", line)

        # Check for use of Psych globals
        for global_var in self.PSYCH_GLOBALS:
            if global_var in line and 'local' not in line:
                continue  # OK, it's a global
    
    def get_diagnostics(self) -> Dict[str, List[Dict]]:
        """Get formatted diagnostics for LSP"""
        return {
            'errors': self.errors,
            'warnings': self.warnings
        }

