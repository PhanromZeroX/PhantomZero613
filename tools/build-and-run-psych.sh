#!/usr/bin/env bash
set -e

# Helper script to build and run Psych Engine (Linux target) from workspace root.
# Usage: ./tools/build-and-run-psych.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PSYCH_DIR="$REPO_ROOT/games/PsychEngine"

if [ ! -d "$PSYCH_DIR" ]; then
  echo "Psych Engine directory not found at: $PSYCH_DIR"
  exit 1
fi

echo "Installing/ensuring Haxelib libs (lime/openfl)..."
haxelib install lime || true
haxelib install openfl || true

cd "$PSYCH_DIR"

echo "Building and launching Psych Engine (linux debug). This may take a while..."
# Use lime test linux if available; fallback to lime build linux.
if command -v lime >/dev/null 2>&1; then
  lime test linux -debug || lime build linux
else
  echo "lime not found in PATH. Ensure haxe/haxelib/lime are installed in your devcontainer." >&2
  exit 2
fi
