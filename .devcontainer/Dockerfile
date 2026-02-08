# Ubuntu 24.04 LTS - Required for Psych Engine 1.0.4 (glibc 2.38+)
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-24.04

# Install system packages for Haxe/Lime/OpenFL + a lightweight desktop + noVNC
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git build-essential ca-certificates gnupg2 lsb-release \
    openjdk-17-jdk python3 python3-pip pkg-config cmake \
    libx11-dev libxrandr-dev libxi-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev \
    xfce4 xfce4-terminal x11vnc net-tools novnc websockify \
    libstdc++6 libssl3 libc6 zlib1g libflac6 libogg0 libvorbis0a libvorbisenc3 libpulse0 \
    libvlc5 libvlccore10 vlc-data \
    && rm -rf /var/lib/apt/lists/*

# Install Lua and luarocks for Lua-based FNF tooling
RUN apt-get update && apt-get install -y --no-install-recommends lua5.4 luarocks \
    && rm -rf /var/lib/apt/lists/*

# Install Haxe 4.3.0+ (required for compiling Psych Engine if needed)
RUN wget -qO /tmp/haxe.tar.gz "https://github.com/HaxeFoundation/haxe/releases/download/4.3.0/haxe-4.3.0-linux64.tar.gz" \
    && tar -xzf /tmp/haxe.tar.gz -C /tmp \
    && mv /tmp/haxe_20230405165950_731dcd7 /opt/haxe \
    && ln -sf /opt/haxe/haxe /usr/local/bin/haxe \
    && ln -sf /opt/haxe/haxelib /usr/local/bin/haxelib \
    && rm /tmp/haxe.tar.gz

# Install Neko VM (required for Haxe)
RUN wget -qO /tmp/neko.tar.gz "https://github.com/HaxeFoundation/neko/releases/download/2.3.0/neko-2.3.0-linux64.tar.gz" \
    && tar -xzf /tmp/neko.tar.gz -C /tmp \
    && mv /tmp/neko-2.3.0-linux /opt/neko \
    && ln -sf /opt/neko/neko /usr/local/bin/neko \
    && ln -sf /opt/neko/nekotools /usr/local/bin/nekotools \
    && rm /tmp/neko.tar.gz

# Setup Haxelib and install Psych Engine dependencies
RUN haxelib newrepo 2>/dev/null || true \
    && haxelib setup /tmp/haxelib 2>/dev/null || true \
    && haxelib install lime 8.0.2 \
    && haxelib install openfl 9.2.2 \
    && haxelib install flixel 5.6.1 \
    && haxelib install flixel-addons 3.2.2 \
    && haxelib install hxcpp 4.3.2 \
    && haxelib install tjson 1.4.0 \
    && haxelib install actuate 1.9.0 \
    && haxelib install format 3.8.0 \
    && haxelib install flxanimate 4.0.0 \
    && haxelib git hxCodec https://github.com/polybiusproxy/hxCodec \
    && haxelib install linc_luajit 0.0.7 \
    && haxelib install hscript-iris 1.1.3 \
    && haxelib install hxdiscord_rpc 1.2.4 \
    && haxelib run lime setup linux

WORKDIR /workspaces/PhantomZero613

COPY .devcontainer/start-novnc.sh /usr/local/bin/start-novnc.sh
RUN chmod +x /usr/local/bin/start-novnc.sh

EXPOSE 6080

CMD ["/bin/bash"]

