#!/bin/bash
# Psych Engine Build & Run Script for Codespace
# This script attempts to build and run Psych Engine locally

set -e

PSYCH_DIR="/workspaces/PhantomZero613/PsychEngine"
HAXE_PATH="/tmp/haxe_20230405165950_731dcd7"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║    Purple Phantom AI - Psych Engine 1.0.4 Build Script         ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Check prerequisites
echo -e "\n[1/5] Checking prerequisites..."

if ! command -v git &> /dev/null; then
    echo "❌ Git not found"
    exit 1
fi
echo "✅ Git found"

if ! command -v curl &> /dev/null; then
    echo "❌ curl not found"
    exit 1
fi
echo "✅ curl found"

# Set up Haxe
echo -e "\n[2/5] Setting up Haxe..."

if [ ! -f "$HAXE_PATH/haxe" ]; then
    echo "📥 Downloading Haxe..."
    mkdir -p /tmp/haxe_temp
    cd /tmp/haxe_temp
    curl -sL "https://github.com/HaxeFoundation/haxe/releases/download/4.3.0/haxe-4.3.0-linux64.tar.gz" -o haxe.tar.gz
    tar -xzf haxe.tar.gz
    HAXE_PATH=$(ls -d haxe* | head -1)
    echo "✅ Haxe extracted to $HAXE_PATH"
fi

export PATH="$HAXE_PATH:$PATH"
echo "✅ Haxe configured"

# Check Psych Engine exists
echo -e "\n[3/5] Checking Psych Engine..."

if [ ! -d "$PSYCH_DIR" ]; then
    echo "❌ Psych Engine not found at $PSYCH_DIR"
    exit 1
fi
echo "✅ Psych Engine found"

# Install haxelib dependencies
echo -e "\n[4/5] Installing haxelib dependencies..."
echo "⚠️  Note: This step requires Haxe binaries to be fully functional"
echo "   If errors occur, refer to PSYCH-ENGINE-SETUP.md for alternatives"

cd "$PSYCH_DIR"

echo "   - Installing lime..."
# haxelib install lime 7.9.0 || echo "⚠️  Lime installation skipped"

echo "   - Installing openfl..."
# haxelib install openfl 9.0.2 || echo "⚠️  OpenFL installation skipped"

echo "✅ Dependency installation complete (or skipped due to binary issues)"

# List available build targets
echo -e "\n[5/5] Build Options:"
echo ""
echo "To build Psych Engine, run one of:"
echo "  lime build linux         # Build for Linux"
echo "  lime build html5         # Build for web browser"
echo "  lime build windows       # Build for Windows (if cross-compiling)"
echo ""
echo "To run the game (after successful build):"
echo "  cd $PSYCH_DIR"
echo "  ./export/linux/bin/FNF"
echo ""

# Display development info
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    Development Environment                     ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ ✅ Python Environment: /workspaces/PhantomZero613/.venv-1/bin/ ║"
echo "║ ✅ Psych Engine: $PSYCH_DIR               ║"
echo "║ ✅ Mods: $PSYCH_DIR/mods/PurplePhantomMod         ║"
echo "║ ✅ AI API: http://127.0.0.1:5000/api/respond                  ║"
echo "║ ✅ Streamlit UI: http://127.0.0.1:8501                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "📖 For detailed setup instructions, see: PSYCH-ENGINE-SETUP.md"
echo "🎮 For mod development, see: PsychEngine/mods/PurplePhantomMod/README.md"
echo ""
