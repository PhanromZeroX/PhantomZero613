#!/bin/bash
# 🎮 Psych Engine 1.0.4 - Start Game & Mods
# This script starts Psych Engine locally (requires successful build)

set -e

GAME_DIR="/workspaces/PhantomZero613/games/PsychEngine"
VENV="/workspaces/PhantomZero613/.venv-1/bin/activate"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}          🎮 Purple Phantom AI - Psych Engine 1.0.4            ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if game is built
if [ ! -f "$GAME_DIR/export/linux/bin/FNF" ]; then
    echo -e "${YELLOW}⚠️  Psych Engine not built yet!${NC}"
    echo ""
    echo "To build the game, you need:"
    echo "  1. Haxe compiler (4.0+)"
    echo "  2. Lime build framework"
    echo "  3. OpenFL library"
    echo ""
    echo "Build command:"
    echo -e "  ${BLUE}cd $GAME_DIR${NC}"
    echo -e "  ${BLUE}lime build linux${NC}"
    echo ""
    echo "For detailed instructions, see:"
    echo "  /workspaces/PhantomZero613/docs/PSYCH-ENGINE-SETUP.md"
    echo ""
    read -p "Continue anyway? (y/n): " continue_anyway
    if [ "$continue_anyway" != "y" ]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ Game binary found${NC}"
fi

echo ""
echo "Available Mods:"
cd "$GAME_DIR/mods"
ls -1d */ 2>/dev/null | nl || echo "  (No mods found)"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🎮 Starting Psych Engine..."
echo ""

cd "$GAME_DIR"

# Check if binary exists
if [ -f "$GAME_DIR/export/linux/bin/FNF" ]; then
    # Try to run with best available graphics settings
    export SDL_VIDEODRIVER=dummy  # Disable video if headless
    
    echo -e "${GREEN}🎮 Launching Psych Engine...${NC}"
    echo "   Mods will be loaded automatically from:"
    echo "   $GAME_DIR/mods/"
    echo ""
    
    # Run the game
    ./export/linux/bin/FNF 2>&1 | head -50
    
    echo ""
    echo -e "${GREEN}✅ Game closed${NC}"
else
    echo -e "${RED}❌ Game binary not found at $GAME_DIR/export/linux/bin/FNF${NC}"
    echo ""
    echo "Build Psych Engine first:"
    echo "  lime build linux -debug"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Run time stats:"
ps aux | grep FNF | grep -v grep || echo "  (Process ended)"
echo ""
echo "✨ Thanks for playing Purple Phantom AI!"
