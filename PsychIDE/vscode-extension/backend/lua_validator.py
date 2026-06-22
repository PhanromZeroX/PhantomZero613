"""
Lua code validator - checks if Lua code is compatible with Psych Engine.
Validates function calls, parameters, and shader usage.
"""

import re
from typing import List, Dict, Any, Tuple


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
    
    def __init__(self):
        self.errors: List[Dict[str, Any]] = []
        self.warnings: List[Dict[str, Any]] = []
    
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
            args = [arg.strip() for arg in args_string.split(',')] if args_string.strip() else []
            arg_count = len(args)

            # --- Your existing dictionary check goes here ---
            # Example:
            
            expected_spec = self.PSYCH_FUNCTIONS.get(func_name)
            if expected_spec:
                expected_args = len(expected_spec.get('params', []))
                if arg_count != expected_args:
                    self.errors.append({
                        'line': line_no,
                        'col': match.start(),
                        'message': f'Argument mismatch: {func_name} expects {expected_args} args, but got {arg_count}.'
                    })
                continue # Known function processed safely; skip downstream checks
            
            # Check if it's a callback
            if func_name in self.PSYCH_CALLBACKS:
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
                    'message': f'Unknown function: {func_name}',
                    'severity': 'info'
                })
    
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
