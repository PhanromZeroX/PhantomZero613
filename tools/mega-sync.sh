#!/bin/bash
# Mega.nz Storage Integration Script for Codespace
# This script provides utilities to sync files with Mega.nz cloud storage

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

STORAGE_DIR="/workspaces/PhantomZero613/storage/mega-sync"
CONFIG_FILE="$STORAGE_DIR/.mega_config"
LOG_FILE="$STORAGE_DIR/mega_sync.log"

# Enable logging
mkdir -p "$STORAGE_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo_step() {
    echo -e "${BLUE}▶${NC} $1"
}

echo_success() {
    echo -e "${GREEN}✅${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

echo_error() {
    echo -e "${RED}❌${NC} $1"
}

# Menu system
show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         Purple Phantom AI - Mega.nz Storage Manager            ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Choose an option:"
    echo "  1) Setup Mega.nz Account (First Time)"
    echo "  2) Download Files from Mega.nz"
    echo "  3) Upload Files to Mega.nz"
    echo "  4) View Storage Status"
    echo "  5) Configure Auto-Sync"
    echo "  6) Exit"
    echo ""
    read -p "Enter choice [1-6]: " choice
}

setup_account() {
    echo_step "Setting up Mega.nz account..."
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo ""
        read -p "Enter your Mega.nz email: " mega_email
        read -sp "Enter your Mega.nz password: " mega_password
        echo ""
        
        # Store credentials (WARNING: This is not production-secure. Use environment variables in production)
        cat > "$CONFIG_FILE" << EOF
MEGA_EMAIL="$mega_email"
MEGA_PASSWORD="$mega_password"
MEGA_ROOT="/workspaces/PhantomZero613/storage/mega-sync"
LAST_SYNC=$(date)
EOF
        chmod 600 "$CONFIG_FILE"
        echo_success "Account configured!"
        log "Mega.nz account setup completed"
    else
        echo_warning "Configuration already exists at $CONFIG_FILE"
        read -p "Overwrite? (y/n): " overwrite
        if [ "$overwrite" = "y" ]; then
            setup_account
        fi
    fi
}

download_files() {
    echo_step "Preparing download from Mega.nz..."
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo_error "Not configured! Run setup first (option 1)"
        return 1
    fi
    
    source "$CONFIG_FILE"
    
    echo_warning "Using mega.py Python library..."
    
    # Create Python script for mega download
    python_script=$(cat << 'PYTHON_CODE'
import os
import sys

try:
    from mega import Mega
    
    email = os.environ.get('MEGA_EMAIL')
    password = os.environ.get('MEGA_PASSWORD')
    
    if not email or not password:
        print("❌ Email and password required. Set MEGA_EMAIL and MEGA_PASSWORD")
        sys.exit(1)
    
    print("🔐 Connecting to Mega.nz...")
    mega = Mega()
    m = mega.login(email, password)
    
    print("✅ Connected!")
    print("📂 Root folder contents:")
    
    files = m.get_files()
    for file_id, file_info in files.items():
        print(f"  - {file_info.get('a', {}).get('n', 'Unknown')}")
    
except ImportError:
    print("⚠️  mega.py not installed. Install with: pip install mega.py")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {str(e)}")
    sys.exit(1)
PYTHON_CODE
)
    
    export MEGA_EMAIL="$mega_email"
    export MEGA_PASSWORD="$mega_password"
    
    python3 << 'END_PYTHON'
import os
import sys

try:
    from mega import Mega
    
    email = os.environ.get('MEGA_EMAIL')
    password = os.environ.get('MEGA_PASSWORD')
    
    if not email or not password:
        print("❌ Email and password required")
        sys.exit(1)
    
    print("🔐 Connecting to Mega.nz...")
    mega = Mega()
    m = mega.login(email, password)
    
    print("✅ Connected to Mega.nz!")
    print("📂 Listing your Mega.nz files...")
    files = m.get_files()
    
    if not files:
        print("   (No files found)")
    else:
        for file_id, file_data in files.items():
            info = file_data.get('a', {})
            name = info.get('n', 'Unknown')
            print(f"   📄 {name}")
    
except ImportError:
    print("⚠️  mega.py library not installed")
    print("   Install with: pip install mega.py")
    
except Exception as e:
    print(f"❌ Error connecting: {str(e)}")
    print("   Check your credentials and try again")
END_PYTHON
    
    log "Download initiated for Mega.nz files"
}

upload_files() {
    echo_step "Preparing upload to Mega.nz..."
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo_error "Not configured! Run setup first (option 1)"
        return 1
    fi
    
    source "$CONFIG_FILE"
    
    echo ""
    echo "Files available for upload:"
    ls -la "$STORAGE_DIR" | grep -v "^\d\.\|config\|\.log" | tail -n +2
    
    echo ""
    read -p "Enter filename to upload (or 'cancel'): " filename
    
    if [ "$filename" != "cancel" ] && [ -f "$STORAGE_DIR/$filename" ]; then
        echo_warning "Upload feature coming soon!"
        echo "   For now, use: mega-cmd mega-put $STORAGE_DIR/$filename"
        log "Upload requested: $filename"
    else
        echo_error "File not found or cancelled"
    fi
}

view_status() {
    echo_step "Mega.nz Storage Status"
    echo ""
    
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo_success "✅ Account configured"
        echo "   Email: ${MEGA_EMAIL:0:3}***"
        echo "   Last sync: $LAST_SYNC"
    else
        echo_warning "⚠️  Not configured yet"
    fi
    
    echo ""
    echo "Local storage:"
    du -sh "$STORAGE_DIR"
    
    echo ""
    echo "Files in storage:"
    ls -1 "$STORAGE_DIR" | grep -v "^\." | wc -l
    echo " files"
}

install_mega_py() {
    echo_step "Installing mega.py library..."
    source /workspaces/PhantomZero613/.venv-1/bin/activate
    pip install mega.py --quiet -q
    echo_success "mega.py installed!"
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1) setup_account ;;
        2) download_files ;;
        3) upload_files ;;
        4) view_status ;;
        5) echo_warning "Auto-sync configuration coming soon!"; read -p "Press Enter..." ;;
        6) echo "Goodbye!"; exit 0 ;;
        *) echo_error "Invalid option"; sleep 1 ;;
    esac
    
    [ "$choice" != "6" ] && read -p "Press Enter to continue..." && clear
done
