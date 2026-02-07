#!/bin/bash
# 📋 Organized Workspace Overview & Quick Links

WORKSPACE="/workspaces/PhantomZero613"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       ${BLUE}Purple Phantom AI + Psych Engine 1.0.4${PURPLE}                  ║"
echo "║          ${CYAN}Organized Workspace Overview${PURPLE}                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${BLUE}📁 WORKSPACE STRUCTURE${NC}"
echo "───────────────────────────────────────────────────────────────"
echo ""

echo -e "${GREEN}📚 Documentation${NC}"
echo "  Location: ${BLUE}docs/${NC}"
ls -1 docs/ | head -5 | sed 's/^/    📄 /'
echo ""

echo -e "${GREEN}🤖 AI Core (Purple Phantom)${NC}"
echo "  Location: ${BLUE}ai-core/${NC}"
ls -1 ai-core/ | grep -E "\.py$|models" | head -5 | sed 's/^/    🐍 /'
echo ""

echo -e "${GREEN}🎮 Games & Mods${NC}"
echo "  Location: ${BLUE}games/${NC}"
echo "    ├── PsychEngine/ (1.2GB)"
echo "    │   ├── mods/"
echo "    │   │   └── ${YELLOW}PurplePhantomMod/${NC} ⭐ Your mod template"
echo "    │   ├── assets/"
echo "    │   ├── source/"
echo "    │   └── Project.xml"
echo ""

echo -e "${GREEN}🛠️  Tools & Scripts${NC}"
echo "  Location: ${BLUE}tools/${NC}"
echo "    ├── ${CYAN}mega-sync.sh${NC}           - Mega.nz cloud storage manager"
echo "    ├── start-psych-engine.sh - Launch Psych Engine"
echo "    └── (Auto-sync scripts)"
echo ""

echo -e "${GREEN}☁️  Cloud Storage${NC}"
echo "  Location: ${BLUE}storage/mega-sync/${NC}"
echo "    ├── README-MEGA-SYNC.md   - Mega.nz integration guide"
echo "    ├── .mega_config          - Your Mega.nz credentials (private)"
echo "    ├── downloads/            - Downloaded files"
echo "    └── uploads/              - Files ready to upload"
echo ""

echo ""
echo -e "${BLUE}🚀 QUICK START COMMANDS${NC}"
echo "───────────────────────────────────────────────────────────────"
echo ""

echo -e "${YELLOW}1. Start Purple Phantom AI (Chatbot)${NC}"
echo "   ${CYAN}source .venv-1/bin/activate${NC}"
echo "   ${CYAN}python ai-core/api_server.py${NC}     # API on port 5000"
echo "   ${CYAN}streamlit run ai-core/app.py${NC}      # UI on port 8501"
echo ""

echo -e "${YELLOW}2. Access Psych Engine Mods${NC}"
echo "   ${CYAN}cd games/PsychEngine/mods/PurplePhantomMod/${NC}"
echo "   ${CYAN}code scripts/phantom_character.lua${NC}  # Edit Lua scripts"
echo "   ${CYAN}code characters/phantom.json${NC}      # Edit character"
echo ""

echo -e "${YELLOW}3. Manage Mega.nz Storage${NC}"
echo "   ${CYAN}bash tools/mega-sync.sh${NC}           # Interactive menu"
echo "   ${CYAN}cd storage/mega-sync${NC}              # Storage folder"
echo ""

echo -e "${YELLOW}4. Build & Run Psych Engine${NC}"
echo "   ${CYAN}cd games/PsychEngine${NC}              # Go to game folder"
echo "   ${CYAN}lime build linux${NC}                  # Build (requires Haxe)"
echo "   ${CYAN}bash ../../tools/start-psych-engine.sh${NC} # Run game"
echo ""

echo ""
echo -e "${BLUE}📊 DIRECTORY SIZES${NC}"
echo "───────────────────────────────────────────────────────────────"
du -sh ai-core 2>/dev/null | awk '{print "  🤖 AI Core:       " $1}'
du -sh games/PsychEngine 2>/dev/null | awk '{print "  🎮 Psych Engine:  " $1}'
du -sh docs 2>/dev/null | awk '{print "  📚 Docs:          " $1}'
du -sh storage 2>/dev/null | awk '{print "  ☁️  Storage:       " $1}'
echo ""

echo ""
echo -e "${BLUE}🔗 IMPORTANT LINKS${NC}"
echo "───────────────────────────────────────────────────────────────"
echo ""
echo "  📖 Setup Guide:"
echo "     ${CYAN}docs/PSYCH-ENGINE-SETUP.md${NC}"
echo ""
echo "  🎮 Modding Guide:"
echo "     ${CYAN}games/PsychEngine/mods/PurplePhantomMod/README.md${NC}"
echo ""
echo "  ☁️  Mega.nz Guide:"
echo "     ${CYAN}storage/mega-sync/README-MEGA-SYNC.md${NC}"
echo ""
echo "  🤖 AI Documentation:"
echo "     ${CYAN}docs/README.md${NC}"
echo ""

echo ""
echo -e "${GREEN}✅ STATUS CHECK${NC}"
echo "───────────────────────────────────────────────────────────────"
echo ""

# Check components
echo -n "  Python 3.12 venv:       "
[ -d ".venv-1" ] && echo -e "${GREEN}✅${NC}" || echo -e "${YELLOW}⚠️${NC}"

echo -n "  Psych Engine source:    "
[ -d "games/PsychEngine" ] && echo -e "${GREEN}✅${NC}" || echo -e "${YELLOW}⚠️${NC}"

echo -n "  PurplePhantomMod:       "
[ -d "games/PsychEngine/mods/PurplePhantomMod" ] && echo -e "${GREEN}✅${NC}" || echo -e "${YELLOW}⚠️${NC}"

echo -n "  mega.py library:        "
source .venv-1/bin/activate 2>/dev/null && python -c "import mega" 2>/dev/null && echo -e "${GREEN}✅${NC}" || echo -e "${YELLOW}⚠️${NC}"

echo -n "  Al Core scripts:        "
[ -f "ai-core/api_server.py" ] && [ -f "ai-core/app.py" ] && echo -e "${GREEN}✅${NC}" || echo -e "${YELLOW}⚠️${NC}"

echo -n "  Documentation:          "
[ -d "docs" ] && [ -f "docs/PSYCH-ENGINE-SETUP.md" ] && echo -e "${GREEN}✅${NC}" || echo -e "${YELLOW}⚠️${NC}"

echo ""

echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "🎯 Next Steps:"
echo ""
echo "  1. Read mod developer guide:"
echo "     ${CYAN}cat games/PsychEngine/mods/PurplePhantomMod/README.md${NC}"
echo ""
echo "  2. Setup Mega.nz storage (optional):"
echo "     ${CYAN}bash tools/mega-sync.sh${NC}"
echo ""
echo "  3. Start developing your mods!"
echo "     ${CYAN}cd games/PsychEngine/mods/PurplePhantomMod/${NC}"
echo ""

echo -e "${GREEN}💡 Pro Tips:${NC}"
echo "  • Edit Lua scripts with ${CYAN}code${NC} or your IDE"
echo "  • Mods reload automatically when building Psych Engine"
echo "  • Use Mega.nz to backup your mods across sessions"
echo "  • Check${CYAN} docs/PSYCH-ENGINE-SETUP.md${NC} for build help"
echo ""

echo -e "${PURPLE}Happy modding! 🚀${NC}"
echo ""
