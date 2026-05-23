# PhantomZero613 Workspace Organization Guide

## 📁 Current Folder Structure (Reorganized)

```
PhantomZero613/
│
├── 🎮 GAMES & MODS (Move to _GAMES_MODS/)
│   ├── games/PsychEngine/            → All Psych Engine builds
│   ├── unknown-suffering-mod/         → FNF mods
│   ├── cataclysm_extracted/          → Extracted cataclysm content
│   └── tmp_altstage_extract/         → Temp extracted stage files
│
├── 🤖 AI & CHATBOT (Move to _AI_CHATBOT/)
│   ├── ai-core/
│   │   ├── app.py                   → Main Streamlit web UI
│   │   ├── Purple_Phantom.py        → Core GPT-2 model
│   │   ├── api_server.py            → API endpoint (optional)
│   │   └── train_conversational_model.py
│   │
│   └── Purple-Phantom.AI/           → Original model folder
│
├── 🛠️ DEVELOPMENT TOOLS (Move to _DEV_TOOLS/)
│   ├── PsychIDE/                    → Psych Engine Modding IDE
│   │   ├── backend/                 → Python LSP server
│   │   ├── vscode-extension/        → VS Code extension
│   │   ├── lua-library/             → Lua type definitions
│   │   └── schemas/                 → JSON schemas
│   │
│   ├── tools/                       → Build scripts
│   │   ├── build-and-run-psych.sh
│   │   ├── build-psych-engine.sh
│   │   ├── mega-sync.sh
│   │   └── start-psych-engine.sh
│   │
│   └── Phantom_Zero[Code Files]/    → Misc Lua/scripts
│
├── 📚 DOCUMENTATION (Move to _DOCUMENTATION/)
│   ├── docs/                        → Psych Engine guides
│   │   ├── PSYCH-ENGINE-LUA-REFERENCE.md
│   │   ├── DEVELOPMENT-WORKFLOWS.md
│   │   └── psych_engine_recipes/
│   │
│   ├── README.md
│   ├── INSTANT-SETUP-README.md
│   ├── Codespace-Build-Instructions.md
│   └── APK-DEPLOYMENT.md
│
├── 💾 STORAGE & DATA (Move to _STORAGE/)
│   └── storage/mega-sync/           → Mega.nz sync storage
│
├── 📦 EXTRACTED/TEMP (Move to _EXTRACTED_ASSETS/)
│   ├── cataclysm_extracted/
│   ├── tmp_altstage_extract/
│   └── unknown-suffering-mod/
│
├── 🧪 TESTING (Move to _TESTS/)
│   ├── test.lua
│   ├── shader_auto_loader.lua
│   ├── heatwave.lua
│   ├── particles.lua
│   └── godrays.lua
│
├── 🔧 BUILD & CONFIG
│   ├── buildozer.spec
│   ├── requirements.txt
│   ├── start.sh
│   ├── instant-codespace-setup.sh
│   └── PSYCH-ENGINE-SETUP-PROGRESS.md
│
└── 🌐 CORE PSYCH ENGINE
    └── PsychEngine-Source/          → Engine source code (read-only)
```

## 🎯 Quick Reference by Purpose

### Working on Psych Engine Mods?
→ `_GAMES_MODS/games/PsychEngine/mods/`

### Developing with Psych IDE?
→ `_DEV_TOOLS/PsychIDE/`

### Shader/Stage Scripts?
→ `_TESTS/` (for testing) or `_GAMES_MODS/` (for production)

### Training/Using the AI Chatbot?
→ `_AI_CHATBOT/ai-core/`

### Need Build Tools?
→ `_DEV_TOOLS/tools/`

### Reading Documentation?
→ `_DOCUMENTATION/docs/`

## 📝 How to Use This Organization

1. **Keep active files flat** (root level for quick access):
   - Main scripts (heatwave.lua, particles.lua, etc.)
   - Configuration (buildozer.spec, requirements.txt)

2. **Archive completed projects** in their category folder

3. **Temp/extracted files** go in `_EXTRACTED_ASSETS/` to keep workspace clean

4. **Experiment safely** in `_TESTS/` before moving to production

---

**Next Steps:** Run the reorganization script to automatically move files into their proper categories.
