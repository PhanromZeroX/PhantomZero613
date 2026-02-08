# Ubuntu 24.04 LTS - Required for Psych Engine 1.0.4 (glibc 2.38+)
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04

# Install system packages for Haxe/Lime/OpenFL + a lightweight desktop + noVNC
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git build-essential ca-certificates gnupg2 lsb-release \
    openjdk-17-jdk python3 python3-pip pkg-config cmake \
    libx11-dev libxrandr-dev libxi-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev \
    xfce4 xfce4-terminal x11vnc net-tools novnc websockify \
    libstdc++6 libssl3 libc6 zlib1g libogg0 libvorbis0a libpulse0 \
    && rm -rf /var/lib/apt/lists/*

# Install Lua and luarocks for Lua-based FNF tooling
RUN apt-get update && apt-get install -y --no-install-recommends lua5.4 luarocks \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell for terminal preference
RUN apt-get update && apt-get install -y --no-install-recommends wget apt-transport-https \
    && wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/24.04/prod.list > /etc/apt/sources.list.d/powershell.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends powershell \
    && rm -rf /var/lib/apt/lists/*

# Note: Haxe is NOT installed via apt - it causes build failures
# If Haxe is needed later, install via binary download AFTER container is built

WORKDIR /workspaces/PhantomZero613

COPY .devcontainer/start-novnc.sh /usr/local/bin/start-novnc.sh
RUN chmod +x /usr/local/bin/start-novnc.sh

# Copy and set execute permissions for postCreateCommand.sh
COPY .devcontainer/postCreateCommand.sh /workspaces/PhantomZero613/.devcontainer/postCreateCommand.sh
RUN chmod +x /workspaces/PhantomZero613/.devcontainer/postCreateCommand.sh

EXPOSE 6080

CMD ["/bin/bash"]

