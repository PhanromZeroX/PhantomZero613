#!/usr/bin/env bash
set -e

# Build script for Psych Engine on Ubuntu 24.04 (glibc 2.38+)
# Usage: ./tools/build-psych-engine.sh

echo "🔨 Building Psych Engine 1.0.4 for Linux..."

cd /workspaces/PhantomZero613/PsychEngine-Source

# Verify Haxe is installed
if ! command -v haxe &> /dev/null; then
    echo "❌ Haxe not found. Please ensure Haxe 4.3.0+ is installed."
    echo "   Ubuntu 24.04 should have it pre-installed in the container."
    exit 1
fi

# Set correct library versions
haxelib set lime 8.0.2
haxelib set openfl 9.2.2

# Build for Linux (release)
echo "📦 Building release binary (this may take 10-20 minutes)..."
haxelib run lime build linux -release

echo "✅ Build complete!"
echo "📂 Binary location: /workspaces/PhantomZero613/PsychEngine-Source/export/release/linux/bin/PsychEngine"

# Copy to games directory
cp /workspaces/PhantomZero613/PsychEngine-Source/export/release/linux/bin/PsychEngine \
   /workspaces/PhantomZero613/games/PsychEngine/export/release/

echo "📋 Copied to: /workspaces/PhantomZero613/games/PsychEngine/export/release/PsychEngine"

