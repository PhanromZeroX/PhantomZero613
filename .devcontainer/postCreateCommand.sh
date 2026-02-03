#!/bin/bash
set -e

# Start noVNC assets if not present (some images are installed by package managers)
if [ ! -d "/workspaces/PhantomZero613/.noVNC" ]; then
  git clone https://github.com/novnc/noVNC.git /workspaces/PhantomZero613/.noVNC || true
  git clone https://github.com/novnc/websockify.git /workspaces/PhantomZero613/.noVNC/utils/websockify || true
fi

echo "Post-create: Haxelib and common packages installed. To run desktop: start-novnc.sh"
