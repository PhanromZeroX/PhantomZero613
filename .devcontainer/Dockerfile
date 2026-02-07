FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Install system packages for Haxe/Lime/OpenFL + a lightweight desktop + noVNC
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git build-essential ca-certificates gnupg2 lsb-release \
    openjdk-11-jdk python3 python3-pip pkg-config cmake \
    libx11-dev libxrandr-dev libxi-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev \
    xfce4 xfce4-terminal x11vnc net-tools novnc websockify \
    libstdc++6 libssl3 libc6 zlib1g \
    libvlc5 libvlccore9 vlc-data \
    libpulse0 libogg0 libflac8 libvorbis0a libvorbisfile3 \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell (pwsh) from Microsoft package repo
RUN wget -q "https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb \
  && dpkg -i /tmp/packages-microsoft-prod.deb || true \
  && apt-get update \
  && apt-get install -y --no-install-recommends powershell \
  && rm -rf /var/lib/apt/lists/* /tmp/packages-microsoft-prod.deb

# Install Lua and luarocks for Lua-based FNF tooling
RUN apt-get update && apt-get install -y --no-install-recommends lua5.4 luarocks \
  && rm -rf /var/lib/apt/lists/*

# Note: Haxe installation removed - not needed for running pre-built Psych Engine 1.0.4 binary
# If Haxe is needed in the future, use the binary installation instead of apt repo
# wget -qO /tmp/haxe.tar.gz "https://github.com/HaxeFoundation/haxe/releases/download/4.3.0/haxe-4.3.0-linux64.tar.gz"

WORKDIR /workspaces/PhantomZero613

COPY .devcontainer/start-novnc.sh /usr/local/bin/start-novnc.sh
RUN chmod +x /usr/local/bin/start-novnc.sh

EXPOSE 6080

CMD ["/bin/bash"]
