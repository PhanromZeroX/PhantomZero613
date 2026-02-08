#!/usr/bin/env bash
set -e

# Helper script to run pre-built Psych Engine (Linux) from workspace root.
# Usage: ./tools/build-and-run-psych.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PSYCH_DIR="$REPO_ROOT/games/PsychEngine"
PSYCH_BIN="$PSYCH_DIR/export/release/PsychEngine"

# Verify we're on Ubuntu 24.04+ (glibc 2.38+)
GLIBC_VERSION=$(ldd --version | head -1 | awk '{print $NF}')
REQUIRED_GLIBC="2.38"

if [ "$(printf '%s\n' "$REQUIRED_GLIBC" "$GLIBC_VERSION" | sort -V | head -n1)" != "$REQUIRED_GLIBC" ]; then
    echo "⚠️  glibc version $GLIBC_VERSION detected (required: $REQUIRED_GLIBC+)"
    echo "   This script requires Ubuntu 24.04 LTS or newer."
    echo ""
    echo "📋 To fix this:"
    echo "   1. Rebuild your codespace with the updated devcontainer"
    echo "   2. VS Code: Ctrl+Shift+P → 'Rebuild Container'"
    echo "   3. Or create a new codespace from the repository"
    exit 1
fi

echo "✅ Ubuntu 24.04+ detected (glibc $GLIBC_VERSION)"

if [ ! -d "$PSYCH_DIR" ]; then
    echo "❌ Psych Engine directory not found at: $PSYCH_DIR"
    exit 1
fi

if [ ! -f "$PSYCH_BIN" ]; then
    echo "❌ Pre-built Psych Engine binary not found at: $PSYCH_BIN"
    echo ""
    echo "📥 Options:"
    echo "   1. Download from GitHub:"
    echo "      wget https://github.com/ShadowMario/FNF-PsychEngine/releases/download/1.0.4/PsychEngine-Linux.zip"
    echo ""
    echo "   2. Build from source:"
    echo "      ./tools/build-psych-engine.sh"
    exit 1
fi

chmod +x "$PSYCH_BIN" 2>/dev/null || true

echo "🎮 Launching Psych Engine 1.0.4..."
echo "   Binary: $PSYCH_BIN"
echo ""

cd "$PSYCH_DIR/export/release"

# Set up environment for headless running
export DISPLAY=:0
export SDL_VIDEODRIVER=dummy

exec "$PSYCH_BIN"

