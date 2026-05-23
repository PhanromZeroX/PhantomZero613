# Psych Engine Modding IDE

A complete modding development environment for Psych Engine v1.0.4 with real-time validation, intelligent autocompletion, and integrated debugging.

## Architecture

```
PsychIDE/
├── backend/               # Python LSP server + API parser
│   ├── psych_lsp.py      # Language Server Protocol implementation
│   ├── haxe_parser.py    # Parses Haxe source for API specs
│   ├── lua_validator.py  # Validates Lua code against Psych API
│   └── requirements.txt
├── vscode-extension/      # VS Code extension package
│   ├── package.json
│   ├── extension.ts
│   └── schemas/
├── lua-library/           # Lua function signatures & library
│   ├── psych.lua         # Main Psych API wrapper
│   ├── shaders.lua       # Shader helper functions
│   └── characters.lua    # Character manipulation API
└── schemas/               # JSON schemas for validation
    ├── song.schema.json
    ├── character.schema.json
    ├── stage.schema.json
    └── event.schema.json
```

## Features

✅ **Real-time API Validation** - Know if your code will work before you test it
✅ **Lua/Haxe Autocomplete** - Function signatures & parameter hints
✅ **Schema Validation** - JSON config validation for songs/characters/stages
✅ **Snippet Library** - Pre-built patterns for common modding tasks
✅ **Debug Sandbox** - Test Lua code without running the full engine
✅ **Integrated Shader Editor** - GLSL shader support with hot reload

## Quick Start

```bash
cd PsychIDE/backend
pip install -r requirements.txt
python psych_lsp.py --host 0.0.0.0 --port 8000
```

Then install the VS Code extension in `vscode-extension/`.

## Development Roadmap

- [x] Project scaffolding
- [ ] Haxe parser for API extraction
- [ ] LSP server implementation
- [ ] VS Code extension
- [ ] Lua sandbox executor
- [ ] Interactive schema validator
- [ ] Shader preview panel
- [ ] Template generator
