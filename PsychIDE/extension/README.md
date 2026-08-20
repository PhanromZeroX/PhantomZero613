# Psych Engine IDE

PsychIDE is a VS Code extension for Psych Engine modding in Lua and Haxe.

## Included tools

- Psych Engine Lua and Haxe language support
- API hover help with beginner examples
- Lua and JSON validation
- Workspace-wide validation
- Sprite-sheet resizing and batch export profiles
- Sprite-sheet frame preview and playback
- Asset health scanning
- Psych Engine debug connection and hot reload commands

## Build a VSIX

From this directory:

```bash
npm install
npm run package
```

The command creates a `psych-ide-<version>.vsix` file in this directory.

## Install in VS Code or Codespaces

1. Open the Extensions view.
2. Select the menu button.
3. Choose **Install from VSIX...**.
4. Select the generated `.vsix` file.

The extension starts its Python language server with `python3`. Install the dependencies in `backend/requirements.txt` in the Codespace or local environment before using server-backed features.
