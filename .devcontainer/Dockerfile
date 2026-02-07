FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Install system packages for Haxe/Lime/OpenFL + a lightweight desktop + noVNC
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git build-essential ca-certificates gnupg2 lsb-release \
    openjdk-11-jdk python3 python3-pip pkg-config cmake \
    libx11-dev libxrandr-dev libxi-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev \
    xfce4 xfce4-terminal x11vnc net-tools novnc websockify \
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

# Install Haxe (official apt repo)
RUN wget -qO - https://haxe.org/keys/haxe-debian.key | gpg --dearmor -o /usr/share/keyrings/haxe-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/haxe-archive-keyring.gpg] https://haxe.org/apt stable main" > /etc/apt/sources.list.d/haxe.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends haxe haxelib gnupg2 curl wget build-essential ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  # Ensure haxelib is initialised and install needed libs in the same layer for reproducibility
  && mkdir -p /usr/lib/haxe/lib \
  && (haxelib setup /usr/lib/haxe/lib || true) \
  && (haxelib install lime || true) \
  && (haxelib install openfl || true)

# Fallback: if `haxe` binary is not present after apt, download official binary and install
RUN if ! command -v haxe >/dev/null 2>&1; then \
    HAXE_VER=4.3.0; \
    echo "haxe not found - attempting fallback install of ${HAXE_VER}"; \
    wget -qO /tmp/haxe.tar.gz "https://github.com/HaxeFoundation/haxe/releases/download/4.3.0/haxe-4.3.0-linux64.tar.gz" || true; \
    mkdir -p /usr/local/haxe; \
    tar -xzf /tmp/haxe.tar.gz -C /usr/local/haxe --strip-components=1 || true; \
    ln -sf /usr/local/haxe/haxe /usr/local/bin/haxe || true; \
    ln -sf /usr/local/haxe/haxelib /usr/local/bin/haxelib || true; \
    (haxelib setup /usr/lib/haxe/lib || true); \
    (haxelib install lime || true); \
    (haxelib install openfl || true); \
  fi

WORKDIR /workspaces/PhantomZero613

COPY .devcontainer/start-novnc.sh /usr/local/bin/start-novnc.sh
RUN chmod +x /usr/local/bin/start-novnc.sh

EXPOSE 6080

CMD ["/bin/bash"]
