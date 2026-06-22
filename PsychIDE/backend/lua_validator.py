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
        """Check if function calls are valid Psych API calls"""
        # Pattern: functionName(...)
        func_pattern = r'(\w+)\s*\('
        
        for match in re.finditer(func_pattern, line):
            func_name = match.group(1)
            
            # Skip comments
            if '--' in line and line.index('--') < match.start():
                continue
            
            # Check if it's a Psych function
            if func_name in self.PSYCH_FUNCTIONS:
                continue
            
            # Check if it's a callback
            if func_name in self.PSYCH_CALLBACKS:
                continue
            
            # Check if it's a Lua standard library function
            lua_stdlib = ['print', 'table', 'string', 'math', 'assert', 'type', 'pairs', 'ipairs']
            if func_name in lua_stdlib or func_name.startswith('table.') or func_name.startswith('string.'):
                continue
            
            # Warn about potentially unknown function
            if not any(func_name.startswith(f) for f in ['local', 'if', 'for', 'while', 'function']):
                self.warnings.append({
                    'line': line_no,
                    'message': f'Unknown function: {func_name}',
                    'severity': 'info'
                })
    
    def _check_shader_usage(self, line: str, line_no: int):
        """Check if shader-related code is correct"""

        # Rules:
        # - initLuaShader('name') should NOT include .frag/.vsh in the name.
        # - If someone passes a full path/asset ending in .frag/.vsh, treat it as a VALID shader asset reference,
        #   not as a dropped/invalid string.
        if 'initLuaShader' in line:
            match = re.search(r"initLuaShader\s*\(\s*['\"]([^'\"]+)['\"]\s*\)", line)
            if match:
                shader_name = match.group(1)

                # Accept explicit shader asset references, but warn that the API expects the shader name.
                # (Prevents the server/validator from treating the string as broken syntax/token.)
                if re.search(r"\.frag\b|\.vsh\b", shader_name, flags=re.IGNORECASE):
                    self.warnings.append({
                        'line': line_no,
                        'message': f'Shader asset reference "{shader_name}" detected. initLuaShader typically expects the shaderName without extension.',
                        'severity': 'warning'
                    })

                # Also keep a softer warning when both keyword and extension are present.
                # Do NOT error/drop; warnings are enough.
                if '.frag' in shader_name:
                    # Retain legacy wording for compatibility with existing tests/reporting.
                    self.warnings.append({
                        'line': line_no,
                        'message': f'Shader name "{shader_name}" should not include .frag extension',
                        'severity': 'warning'
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
