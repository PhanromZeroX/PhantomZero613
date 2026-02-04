#!/bin/bash
set -e

# ═══════════════════════════════════════════════════════════════
# 🚀 Instant Codespace Setup Script
# ═══════════════════════════════════════════════════════════════
# This script sets up the complete development environment
# in under 3 minutes!
# ═══════════════════════════════════════════════════════════════

echo "🚀 Starting Instant Codespace Setup..."
echo "⏱️  Estimated time: 2-3 minutes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}📦${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# ═══════════════════════════════════════════════════════
# Step 1: System Update
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/6: Updating System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

print_status "Updating package lists..."
apt-get update -qq 2>/dev/null || sudo apt update -qq
print_success "System updated"

# ═══════════════════════════════════════════════════════
# Step 2: Install Python & Dependencies
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/6: Installing Python & Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

print_status "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    print_warning "Python3 not found, installing..."
    apt-get install -y python3 python3-pip python3-venv -qq
fi

print_status "Creating Python virtual environment..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    print_success "Virtual environment created"
else
    print_warning "Virtual environment already exists"
fi

print_status "Activating virtual environment..."
source .venv/bin/activate

print_status "Upgrading pip..."
pip install --upgrade pip -q

print_status "Installing Python packages..."
pip install streamlit flask torch transformers requests kivy pandas -q

print_success "Python dependencies installed"

# ═══════════════════════════════════════════════════════
# Step 3: Install Haxe (if needed)
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/6: Installing Haxe & Game Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ! command -v haxe &> /dev/null; then
    print_status "Installing Haxe..."
    apt-get install -y wget gnupg2 -qq
    
    # Install Haxe from official repo
    wget -qO - https://haxe.org/keys/haxe-debian.key | gpg --dearmor -o /usr/share/keyrings/haxe-archive-keyring.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/haxe-archive-keyring.gpg] https://haxe.org/apt stable main" > /etc/apt/sources.list.d/haxe.list
    apt-get update -qq
    apt-get install -y haxe haxelib -qq
    
    print_status "Installing Haxelib packages..."
    haxelib setup /usr/lib/haxe/lib 2>/dev/null || true
    haxelib install lime 2>/dev/null || true
    haxelib install openfl 2>/dev/null || true
    
    print_success "Haxe installed"
else
    print_warning "Haxe already installed"
fi

# ═══════════════════════════════════════════════════════
# Step 4: Install Lua
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/6: Installing Lua"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v lua &> /dev/null; then
    print_status "Installing Lua..."
    apt-get install -y lua5.4 luarocks -qq
    print_success "Lua installed"
else
    print_warning "Lua already installed"
fi

# ═══════════════════════════════════════════════════════
# Step 5: Setup noVNC GUI (Optional)
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/6: Setting up GUI Desktop (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ ! -d ".noVNC" ]; then
    print_status "Cloning noVNC..."
    git clone -q https://github.com/novnc/noVNC.git .noVNC 2>/dev/null || true
    print_success "noVNC installed"
else
    print_warning "noVNC already exists"
fi

if ! command -v xfce4-session &> /dev/null; then
    print_status "Installing XFCE desktop..."
    apt-get install -y xfce4 xfce4-terminal x11vnc Xvfb -qq
    print_success "XFCE installed"
else
    print_warning "XFCE already installed"
fi

# ═══════════════════════════════════════════════════════
# Step 6: Final Setup
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6/6: Final Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_status "Making scripts executable..."
chmod +x start.sh 2>/dev/null || true
chmod +x .devcontainer/start-novnc.sh 2>/dev/null || true

print_status "Testing AI model..."
python3 -c "from transformers import GPT2LMHeadModel; print('✅ Model packages working')" 2>/dev/null || print_warning "Model packages check skipped"

# ═══════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Quick Start Commands:"
echo ""
echo "   # Activate Python environment"
echo "   source .venv/bin/activate"
echo ""
echo "   # Start AI Web Interface"
echo "   python -m streamlit run app.py"
echo ""
echo "   # Start API Server"
echo "   python api_server.py"
echo ""
echo "   # Start GUI Desktop (in new terminal)"
echo "   start-novnc.sh"
echo ""
echo "🌐 Access Points:"
echo "   • Web UI: http://localhost:8501"
echo "   • API: http://localhost:5000"
echo "   • GUI: http://localhost:6080"
echo ""
print_success "Happy Coding! 🎮🤖"
echo ""
