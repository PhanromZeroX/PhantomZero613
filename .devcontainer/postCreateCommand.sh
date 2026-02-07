#!/bin/bash
set -e

# Install Python dependencies for Purple Phantom AI and mega.nz integration
python3 -m pip install --quiet --upgrade pip
python3 -m pip install --quiet mega.py streamlit pandas requests flask numpy pillow pyarrow

# Setup mega.nz storage directories
mkdir -p /workspaces/PhantomZero613/storage/mega-sync/{downloads,uploads}
echo ".mega_config" > /workspaces/PhantomZero613/storage/mega-sync/.gitignore

# Start noVNC assets if not present (some images are installed by package managers)
if [ ! -d "/workspaces/PhantomZero613/.noVNC" ]; then
  git clone https://github.com/novnc/noVNC.git /workspaces/PhantomZero613/.noVNC || true
  git clone https://github.com/novnc/websockify.git /workspaces/PhantomZero613/.noVNC/utils/websockify || true
fi

echo "Post-create: Haxelib, noVNC, and Python packages installed. mega.nz storage ready at storage/mega-sync/"
