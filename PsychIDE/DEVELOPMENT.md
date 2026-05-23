# Psych Engine IDE - Development Guide

## Project Structure

```
PsychIDE/
├── backend/                    # Python LSP server
│   ├── psych_lsp.py           # Main LSP server
│   ├── haxe_parser.py         # Parse Psych Engine Haxe source
│   ├── lua_validator.py       # Validate Lua against Psych API
│   └── requirements.txt
├── vscode-extension/           # VS Code extension
│   ├── extension.ts           # Extension main file
│   ├── package.json           # Extension manifest
│   └── snippets/              # Code snippets
├── lua-library/                # Lua type definitions
│   ├── psych.lua              # Main Psych API
│   └── shaders.lua            # Shader helpers
└── schemas/                    # JSON schemas
    ├── song.schema.json
    └── character.schema.json
```

## Key Features

### 1. Real-time Validation
The `lua_validator.py` checks:
- ✅ Function call validity against Psych Engine API
- ✅ Shader uniform naming and types
- ✅ Parameter counts match function signatures
- ✅ Global variable usage

### 2. Autocompletion
The LSP server provides:
- Function signatures with parameter hints
- Global variable definitions
- Callback function stubs
- Shader preset snippets

### 3. Type Definitions
Lua library provides documented types:
```lua
local Psych = require('lib/psych')

-- Get autocomplete for all Psych functions
Psych.initLuaShader('heatwave')
Psych.setSpriteShader('myShader', 'heatwave')
Psych.setShaderFloat('myShader', 'strength', 0.5)
```

### 4. Shader Management
Helper library for common patterns:
```lua
local Shaders = require('lib/shaders')

-- Activate heatwave with animation
local update = Shaders.heatwave('heatwaveShader', 0.5, 0.5)

function onUpdatePost(elapsed)
    update()  -- Update shader time uniform
end
```

## Using the Library System

### Import Psych Library
```lua
local Psych = require('PsychIDE/lua-library/psych')

function onStartCountdown()
    Psych.debug('Game starting')
    Psych.initLuaShader('particles')
end
```

### Use Shader Presets
```lua
local Shaders = require('PsychIDE/lua-library/shaders')

function onStartCountdown()
    if shadersEnabled then
        -- Activate particles with custom color
        Shaders.particles('particlesShader', {1.0, 0.5, 0.2}, 8)
    end
end
```

### Example: Shader with Library
```lua
local Shaders = require('PsychIDE/lua-library/shaders')

local updateShader = nil

function onStartCountdown()
    if shadersEnabled then
        -- Create animated heatwave shader
        updateShader = Shaders.heatwave('heatwaveShader', 0.8, 1.0)
    end
end

function onUpdatePost(elapsed)
    if updateShader then
        updateShader()  -- Updates time uniform
    end
end
```

## Development Workflow

### 1. Code in VS Code
- Get real-time autocomplete for Psych functions
- Hover over functions to see documentation
- Type errors appear as red squiggles

### 2. Validation
- Run `Psych: Validate Lua File` command
- JSON schemas auto-validate song.json/character.json
- Diagnostics appear in Problems panel

### 3. Testing
- Use sandbox to test Lua code without running engine
- LSP provides function signature verification
- Quick access to documentation via hover

## Adding New Psych API Functions

1. Add function to `lua_validator.py` PSYCH_FUNCTIONS dict:
```python
'newFunction': {'params': ['param1', 'param2'], 'return': 'returnType'},
```

2. Add typed wrapper to `lua-library/psych.lua`:
```lua
---@param param1 string Description
---@param param2 number Description
---@return nil
function Psych.newFunction(param1, param2)
    newFunction(param1, param2)
end
```

3. Autocomplete and validation automatically work

## Testing

```bash
# Test validator
python -m pytest backend/test_validator.py

# Test LSP
python backend/psych_lsp.py

# Build extension
cd vscode-extension
npm install
npm run compile
```

## Future Enhancements

- [ ] GLSL shader preview panel
- [ ] Integrated debugger connecting to running Psych Engine
- [ ] Visual mod template generator
- [ ] Character/Stage animator preview
- [ ] Multiplayer chart editor
- [ ] Hot reload for development
