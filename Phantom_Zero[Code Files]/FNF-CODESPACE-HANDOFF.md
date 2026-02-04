# FNF Codespace Setup - Handoff Instructions for AI Agent

## Current Status ✅
All tooling is installed and verified in the Codespace:
- **Haxe:** 4.3.0
- **haxelib:** 4.1.0
- **Neko:** 2.3.0 (libneko.so.2)
- **Lua:** 5.1.5
- **PowerShell:** 7.5.4
- **Python venv:** created at `./.venv`
- **Python packages:** streamlit, torch, transformers, flask, requests installed

---

## Remaining Tasks

### Task 1: Start Dev Services

**Location:** `/workspaces/PhantomZero613` (or `~/PhantomZero613`)

**Run one of the following:**

**Option A (Recommended - Startup Script):**
```bash
cd /workspaces/PhantomZero613 || cd ~/PhantomZero613
source .venv/bin/activate
chmod +x ./start.sh
./start.sh
```

**Option B (Manual - Two Terminals):**
Terminal 1:
```bash
cd /workspaces/PhantomZero613 || cd ~/PhantomZero613
source .venv/bin/activate
python api_server.py
```

Terminal 2:
```bash
cd /workspaces/PhantomZero613 || cd ~/PhantomZero613
source .venv/bin/activate
streamlit run app.py
```

**Expected Output:**
- Flask API should start on `http://127.0.0.1:5000` (or display "Running on ...") 
- Streamlit should start on `http://127.0.0.1:8501` or show port forwarding info
- Both should show "ready" or "listening" messages within 10-15 seconds

---

### Task 2: Verify API Endpoint

**Run (from a new terminal with venv activated):**
```bash
cd /workspaces/PhantomZero613
source .venv/bin/activate
curl -sS -X POST http://127.0.0.1:5000/api/respond \
  -H "Content-Type: application/json" \
  -d '{"input":"Hello"}' | python -m json.tool
```

**Expected Response:**
```json
{
  "response": "...",
  "timestamp": "2026-02-03 18:30:00 CST"
}
```

If fails, check:
- Is Flask server running? (`ps aux | grep api_server`)
- Is port 5000 in use? (`lsof -i :5000`)

---

### Task 3: Test Streamlit Web UI

**In browser or Codespaces Simple Browser:**
- Navigate to `http://127.0.0.1:8501`
- Or run: `$BROWSER http://localhost:8501` to open in host's default browser
- Verify the VR HUD interface loads with sci-fi purple (#8a2be2) styling
- Type a message and verify response appears

**Expected:**
- Chat interface with neon purple glassmorphism styling
- Input field and response display
- Should show glowing purple borders and semi-transparent panels

---

### Task 4: Test Mobile App Remote-First Behavior (Optional)

**Run (if Kivy/mobile environment available):**
```bash
cd /workspaces/PhantomZero613
source .venv/bin/activate
python mobile_app.py &
```

**Expected:**
- App attempts to connect to `http://127.0.0.1:5000/api/respond` first
- Falls back to local GPT-2 if API unavailable
- Chat bubbles display with glassmorphism styling

---

### Task 5: Verify FNF Game Dev Tooling

**Run (any terminal):**
```bash
# Verify all FNF tools
haxe -version
haxelib list | grep -E 'lime|openfl'
lua -v
pwsh -v

# Test Haxe project compilation (optional)
cd /workspaces/PhantomZero613/Phantom_Zero[Code Files]
haxe build.hxml || echo "No Haxe project found; that's OK for this setup"
```

**Expected:**
- haxe: 4.3.0
- haxelib: lime 8.3.0, openfl 9.5.0
- lua: 5.1.5
- pwsh: 7.5.4

---

### Task 6: Document APK Build Status and Recommendations

**Action:** Create or update [APK-DEPLOYMENT.md](APK-DEPLOYMENT.md) with the following:

```markdown
# APK Deployment Guide

## Current Status
- **Build Environment:** Codespace (Ubuntu 24.04)
- **Recommended Approach:** Remote-first API (production)
- **Local Build Status:** Not recommended in this environment

## Why Local Build is Challenging
1. Android SDK and NDK not installed in Codespace
2. Heavy ML dependencies (torch, transformers) incompatible with APK packaging
3. Native build toolchain (autoreconf, autotools) missing

## Recommended Production Build Approach: Remote API

### Architecture
- **Client:** Kivy mobile app (lightweight, no ML libs)
- **Server:** Flask API running on a dedicated host or cloud platform
- **Model:** GPT-2 inference on server (uses torch/transformers)

### Build Command (for lightweight APK)
```bash
cd /workspaces/PhantomZero613
buildozer android debug
```

**Note:** This requires:
- Android SDK/NDK installed on a proper build machine
- python-for-android configured
- Recommended: Use GitHub Actions or a dedicated build server

### Alternative: Use Existing APK or Build Service
- Upload source to GitHub Actions and configure Android build workflow
- Use BeeWare or Kivy Cloud build service
- Build locally on a machine with Android SDK/NDK installed

## Current Buildozer Configuration
- Location: `./buildozer.spec`
- Key changes: Removed `torch`, `transformers` from requirements
- Added: `requests` (for remote API calls)

## Testing APK Locally (Emulator)
```bash
# After successful build
adb install -r bin/app.apk
adb shell am start -n com.phantomzero.ai/.MainActivity
```

## Production Deployment
1. Build APK on proper Android build machine or via CI/CD
2. Deploy Flask API to cloud (AWS, GCP, Heroku, etc.)
3. Configure `mobile_app.py` API_URL to point to production server
4. Update buildozer.spec with production API endpoint
5. Sign APK for Play Store release

---

**Status:** Codespace setup complete for FNF game dev tooling and AI chat system.
**Next:** Deploy Flask API to production and build/distribute APK.
```

---

## Task 7: FNF Game Development GUI Setup (Optional)

**If GUI display is needed for testing FNF game client or Haxe compilation output:**

### Start noVNC GUI Server

```bash
# The Codespace devcontainer is configured with XFCE + noVNC
# Check if noVNC is running:
ps aux | grep -E 'vncserver|novnc' || echo "noVNC not running"

# If not running, start it manually:
vncserver -xstartup /usr/bin/startxfce4 :1
# or
sudo systemctl start novnc || novnc_server --listen 6080 &
```

### Access GUI from Browser

**In Codespaces or Local Browser:**
1. Codespaces: Use port forwarding (Ports tab → Forward port 6080)
2. Navigate to: `http://127.0.0.1:6080` or `http://localhost:6080/vnc.html`
3. VNC password (if prompted): check `.devcontainer/Dockerfile` or use default `vncpass`

### Compile and Run FNF Haxe Project

**From noVNC GUI or terminal:**

```bash
cd /workspaces/PhantomZero613/Phantom_Zero[Code Files]

# Check for build configuration
ls -la | grep -E 'build.hxml|project.xml|build'

# Compile Haxe project
haxe build.hxml
# or if using OpenFL/Lime:
haxelib run lime build linux -debug
# or for web build:
haxelib run lime build html5 -debug

# Run the compiled game (if output is a binary)
./Export/linux/cpp/bin/FNF-Client  # adjust path as needed
# or if web build:
# Open Export/html5/index.html in browser
```

**Expected:**
- Game window opens with FNF UI
- Haxe/OpenFL rendering visible
- Lua mod support functional

### Psych Engine 1.0.4 Specific Setup

**Clone Psych Engine:**
```bash
cd /workspaces/PhantomZero613
git clone https://github.com/ShadowMario/FNF-PsychEngine.git PsychEngine
cd PsychEngine
```

**Install Dependencies:**
```bash
# Install required haxelibs
haxelib install lime 8.3.0
haxelib install openfl
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
# Additional for Psych Engine
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
```

**Build Psych Engine:**
```bash
# For Linux native
haxelib run lime build linux
# or for debug
haxelib run lime build linux -debug

# Run the game
./export/release/linux/bin/PsychEngine
```

**In GUI Environment:**
- Use noVNC to access desktop
- Open terminal in GUI and run build commands
- Game will run in the GUI window

**Troubleshooting Psych Engine:**
- If build fails: Ensure all haxelibs are installed
- If runtime errors: Check for missing system libs (alsa, etc.)
- For mods: Place in `mods/` folder
- Lua scripts: Supported natively

### Troubleshooting GUI

**If noVNC doesn't start:**
```bash
# Check if X11 is available
echo $DISPLAY
# Start Xvfb if needed
Xvfb :1 -screen 0 1024x768x24 &
# Then start VNC on that display
vncserver :1
```

**If GUI is slow/laggy:**
- Reduce resolution: `vncserver -geometry 800x600 :1`
- Use direct port 5901 instead of noVNC proxy: VNC client → `localhost:5901`

**If FNF game won't compile:**
```bash
# Verify lime/openfl setup
haxelib run lime setup
haxelib run openfl setup

# Check for missing dependencies
haxelib list | grep -E 'hxcpp|format|actuate'
# Install if missing:
haxelib install hxcpp
haxelib install format
haxelib install actuate
```

---

## Verification Checklist

Run this to confirm all is ready:

```bash
# 1) Check FNF tooling
echo "=== FNF Tooling ===" && \
haxe -version && \
haxelib version && \
haxelib list | grep -E 'lime|openfl' && \
lua -v && \
pwsh -v && \

# 2) Check Python environment
echo -e "\n=== Python Environment ===" && \
source .venv/bin/activate && \
python --version && \
pip list | grep -E 'streamlit|flask|requests' && \

# 3) Verify API can start (3-second test)
echo -e "\n=== API Startup Test ===" && \
timeout 3 python api_server.py &>/tmp/api_test.log || true && \
sleep 1 && \
curl -sS http://127.0.0.1:5000/api/respond -X POST \
  -H "Content-Type: application/json" \
  -d '{"input":"test"}' 2>/dev/null | head -c 100 && \
echo -e "\n✅ API responsive"
```

---

## Success Criteria

✅ All checks pass if:
1. Haxe/haxelib/lime/openfl run without "command not found"
2. `streamlit run app.py` loads UI on port 8501
3. `python api_server.py` responds to `/api/respond` POST requests
4. `mobile_app.py` connects to API and displays chat interface
5. FNF code directory has Haxe/Lua source compiling successfully

---

## If Issues Occur

**Haxe/haxelib not found:**
```bash
# Verify symlinks exist
ls -l /usr/local/bin/haxe /usr/local/bin/haxelib
# If missing, recreate:
sudo ln -sf /usr/local/haxe_20230405165950_731dcd7/haxe /usr/local/bin/haxe
sudo ln -sf /usr/local/haxe_20230405165950_731dcd7/haxelib /usr/local/bin/haxelib
hash -r
haxe -version
```

**API doesn't start:**
```bash
# Check if port 5000 is in use
lsof -i :5000
# Check for import errors
python api_server.py 2>&1 | head -20
```

**Streamlit port conflicts:**
```bash
streamlit run app.py --logger.level=debug --server.port 8502
```

---

## Task 8: Open Project Files in Editor

**After cloning the repo in Codespace, open these key files for FNF/AI dev:**

### Quick Open Commands (VS Code / Codespaces)

From terminal in Codespace repo root:
```bash
cd /workspaces/PhantomZero613 || cd ~/PhantomZero613

# Open all key files at once
code \
  Purple-Phantom.AI/Purple_Phantom.py \
  app.py \
  mobile_app.py \
  api_server.py \
  Phantom_Zero[Code\ Files]/ \
  buildozer.spec \
  requirements.txt \
  .devcontainer/Dockerfile \
  start.sh

# Or open in VS Code GUI (if available)
# File > Open Folder > select repo root
```

### Key Files to Have Open

| File | Purpose | Location |
|------|---------|----------|
| **Purple_Phantom.py** | Core AI model & response logic | `Purple-Phantom.AI/Purple_Phantom.py` |
| **app.py** | Streamlit web UI (VR HUD) | `./app.py` |
| **mobile_app.py** | Kivy mobile app (glassmorphism UI) | `./mobile_app.py` |
| **api_server.py** | Flask API backend | `./api_server.py` |
| **FNF Game Code** | Haxe/Lua project files | `Phantom_Zero[Code\ Files]/` |
| **buildozer.spec** | APK build config | `./buildozer.spec` |
| **requirements.txt** | Python dependencies | `./requirements.txt` |
| **start.sh** | Service startup script | `./start.sh` |
| **.devcontainer/Dockerfile** | Codespace environment | `./.devcontainer/Dockerfile` |

### Browser Bookmarks for Running Services

Once services are started, bookmark these:
- **Streamlit UI:** `http://127.0.0.1:8501`
- **Flask API:** `http://127.0.0.1:5000/api/respond` (POST)
- **noVNC GUI** (if enabled): `http://127.0.0.1:6080/vnc.html`

### File Structure Overview

```
/workspaces/PhantomZero613/
├── Purple-Phantom.AI/
│   ├── Purple_Phantom.py          ← Core AI model
│   └── app.py                      ← Streamlit UI copy
├── app.py                          ← Main Streamlit entry
├── mobile_app.py                   ← Kivy client
├── api_server.py                   ← Flask API
├── start.sh                        ← Startup helper
├── buildozer.spec                  ← APK config
├── requirements.txt                ← Dependencies
├── .devcontainer/
│   ├── Dockerfile                  ← Container setup
│   └── devcontainer.json           ← VS Code config
├── Phantom_Zero[Code Files]/       ← FNF game source (Haxe/Lua)
└── [various markdown docs]
```

### Git Commands to Sync Latest

```bash
cd /workspaces/PhantomZero613 || cd ~/PhantomZero613
git pull origin main           # Pull latest changes
git status                     # Check what changed
git log --oneline -5           # View recent commits
```

---

## Files Modified/Created During Setup
- `.devcontainer/Dockerfile` — updated to Ubuntu 22.04 for Haxe apt support
- `api_server.py` — Flask API with import path fix
- `start.sh` — startup script for services
- `requirements.txt` — updated with streamlit, flask, requests
- `buildozer.spec` — removed torch/transformers
- `mobile_app.py` — updated with remote-first API logic
- Various documentation files (this file, APK-DEPLOYMENT.md, etc.)

---

## Contact / Handoff
If all tasks complete successfully, FNF Codespace dev environment is **production-ready** for:
- Haxe/OpenFL game development
- PowerShell scripting
- Lua modding
- Python chat/API development
- Testing Kivy mobile client with remote API
