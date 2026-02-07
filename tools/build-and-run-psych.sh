#!/usr/bin/env bash
set -e

# Helper script to run pre-built Psych Engine (Linux) from workspace root.
# Usage: ./tools/build-and-run-psych.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PSYCH_DIR="$REPO_ROOT/games/PsychEngine"
PSYCH_BIN="$PSYCH_DIR/export/release/PsychEngine"

# Check if container is Alpine (incompatible with glibc binary)
if grep -qi "Alpine" /etc/os-release 2>/dev/null; then
  echo "════════════════════════════════════════════════════════════════════════"
  echo "⚠️  Alpine Linux Detected - Binary Not Compatible"
  echo "════════════════════════════════════════════════════════════════════════"
  echo ""
  echo "The Psych Engine binary requires Ubuntu (glibc), but this container is"
  echo "Alpine Linux (musl libc). They are not compatible."
  echo ""
  echo "📋 OPTIONS:"
  echo ""
  echo "1. REBUILD THIS CODESPACE (Recommended for immediate testing)"
  echo "   • VS Code: Ctrl+Shift+P → 'Rebuild Container'"
  echo "   • Wait 3-5 minutes for Ubuntu 22.04 to install"
  echo "   • Binary will be ready to run"
  echo ""
  echo "2. CREATE A NEW CODESPACE"
  echo "   • New Codespaces use the updated Dockerfile (Ubuntu 22.04)"
  echo "   • Binary and dependencies are pre-installed"
  echo "   • Recommended for future sessions"
  echo ""
  echo "3. PREPARE MODS IN PARALLEL"
  echo "   • Add assets to: games/PsychEngine/mods/PurplePhantomMod/"
  echo "   • When you rebuild to Ubuntu, mods will load automatically"
  echo ""
  echo "📖 For more details, see: .devcontainer/PSYCH-ENGINE-SETUP.md"
  echo "════════════════════════════════════════════════════════════════════════"
  exit 1
fi

if [ ! -d "$PSYCH_DIR" ]; then
  echo "❌ Psych Engine directory not found at: $PSYCH_DIR"
  exit 1
fi

if [ ! -f "$PSYCH_BIN" ]; then
  echo "❌ Pre-built Psych Engine binary not found at: $PSYCH_BIN"
  echo "📥 Please download from:"
  echo "   https://github.com/ShadowMario/FNF-PsychEngine/releases/download/1.0.4/PsychEngine-Linux.zip"
  exit 1
fi

chmod +x "$PSYCH_BIN" || true

echo "✅ Launching Psych Engine 1.0.4 (Linux pre-built)..."
echo "   Binary: $PSYCH_BIN"
echo ""
cd "$PSYCH_DIR/export/release"
exec "$PSYCH_BIN"
