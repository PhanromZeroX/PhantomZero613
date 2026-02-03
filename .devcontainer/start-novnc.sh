#!/bin/bash
set -e

# Launch a lightweight XFCE desktop and noVNC server accessible on port 6080
export DISPLAY=:1
Xvfb :1 -screen 0 1280x800x16 &
sleep 1
dbus-launch xfce4-session &
sleep 2

# start websockify to bridge VNC to Web
if [ -d "/workspaces/PhantomZero613/.noVNC" ]; then
  /workspaces/PhantomZero613/.noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &
  echo "noVNC running on http://localhost:6080/"
else
  echo "noVNC not found; run postCreateCommand to clone it."
fi

tail -f /dev/null
