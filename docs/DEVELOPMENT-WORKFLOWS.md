# Purple Phantom AI - Development Workflows

## Overview
This document outlines how to work with the Purple Phantom AI codebase across multiple environments:
- **Main Workspace** (`/workspaces/PhantomZero613`) - Core model, Streamlit UI, API server
- **FNF Coding Space** (Codespaces with devcontainer) - FNF game development environment
- **Mobile Development** - Kivy APK updates synchronized with model changes

---

## 1. PowerShell Terminal Setup ✅

### Current Workspace
PowerShell 7.5.4 is installed and ready:

```bash
# Run PowerShell scripts in this workspace
~/.local/pwsh/pwsh -c 'Write-Host "Hello from PowerShell"'

# Set as default terminal in VS Code
# Go to View → Terminal → Select Default Profile → pwsh
```

### Codespaces (FNF Environment)
PowerShell will be automatically available after rebuilding the devcontainer:
1. Click **"Rebuild Container"** in VS Code (when working in Codespaces)
2. Once rebuilt, PowerShell terminal will be available alongside bash/zsh

---

## 2. Training the Torch Transformer Model

### Prerequisites
Ensure all packages are installed:
```bash
pip install torch transformers tensorflow streamlit pandas requests flask kivy buildozer
```

### Training Workflow
```bash
# Navigate to workspace root
cd /workspaces/PhantomZero613

# Run training script (generates 5,000 conversational samples)
python train_conversational_model.py

# Output saved to:
# ./purple_phantom_conversational_model/
#   ├── pytorch_model.bin          (trained GPT-2 weights)
#   └── tokenizer.json
```

**Training Details:**
- Generates synthetic user ↔ AI conversation pairs
- Fine-tunes GPT-2 via HuggingFace Transformers
- Max tokens: 50
- Sampling strategy: top-p + top-k
- Enforces CPU execution (`CUDA_VISIBLE_DEVICES=''`)

### Time Required
~5–15 minutes on standard hardware (CPU-based)

---

## 3. Running the API Server + Streamlit UI (Remote-First Architecture)

### Step 1: Start Flask API Server
```bash
# Terminal 1 - API Server (hosts model inference)
cd /workspaces/PhantomZero613
export FLASK_ENV=development
python api_server.py
# Server listens on: http://localhost:8080/api/respond
```

### Step 2: Start Streamlit Web UI
```bash
# Terminal 2 - Streamlit UI (calls remote API)
cd /workspaces/PhantomZero613
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
streamlit run app.py
# Web interface at: http://localhost:8501
```

### Step 3: (Optional) Run Local Model Only
If you prefer local inference without API:
```bash
# Unset REMOTE_API_URL to use local model
unset REMOTE_API_URL
streamlit run app.py
```

---

## 4. Updating Mobile App with New Model

### Workflow: Train → Export → Deploy to Mobile

#### Step 1: Train New Model (see Section 2)
```bash
python train_conversational_model.py
# Saves to ./purple_phantom_conversational_model/
```

#### Step 2: Test with Streamlit & API
```bash
# Verify model works in web UI first
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
streamlit run app.py
```

#### Step 3: Update Mobile App Configuration
```bash
# Edit mobile_app.py to point to your model
# (Mobile app prefers REMOTE_API_URL if set, else uses local model)

# Set environment variable before building APK:
export REMOTE_API_URL="https://your-deployed-api.com/api/respond"
```

#### Step 4: Build APK (requires Android SDK/NDK)
```bash
buildozer android debug
# Output: bin/purple_phantom-0.1-debug.apk
```

#### Step 5: Install & Test on Device
```bash
# Transfer APK to Android device and install
# Mobile app will connect to REMOTE_API_URL for responses
```

---

## 5. FNF Coding Space (Codespaces Devcontainer)

### What's Available in FNF Environment

The `.devcontainer/Dockerfile` provides:
- **Haxe 4.3+** - Friday Night Funkin' primary language
- **Lime/OpenFL** - Game framework (HaxeFlixel)
- **XFCE Desktop + noVNC** - GUI via browser (port 6080)
- **Lua + Luarocks** - Psych Engine scripting
- **PowerShell 7.5.4** - PowerShell terminal (after rebuild)

### Starting Codespaces

1. **Fork/Clone in GitHub Codespaces:**
   - Go to your repo → **Code** → **Codespaces** → **Create codespace on main**
   - VS Code opens in browser
   - Devcontainer auto-builds (first time: ~3–5 min)

2. **Access GUI (noVNC):**
   - Once container is ready, ports forward
   - Click **"Ports"** tab → find **6080 → noVNC**
   - Click the URL to open XFCE desktop in browser
   - XFCE terminal ready for `haxe`, `lime`, `lua` commands

### FNF Development Commands

#### Compile Friday Night Funkin' (Psych Engine)
```bash
# Inside Codespaces terminal
haxe build.hxml

# Or with Lime (cross-platform)
lime build windows -D release
```

#### Write/Edit Lua Scripts (Psych Engine)
```bash
# Edit Lua mods in /mods folder
nano mods/my_script.lua

# Test in game
lua /path/to/script.lua
```

#### Test Haxe Code
```bash
haxe -main Test -js test.js
node test.js
```

### Workflow: Develop FNF Content, Train Model, Update Mobile

You can work on FNF content **and** update the Purple Phantom model from the same Codespaces environment:

```bash
# Terminal 1 (Codespaces): Work on FNF mods
haxe build.hxml

# Terminal 2 (Codespaces): Train new model
python train_conversational_model.py

# Then sync back to main workspace to deploy APK updates
```

---

## 6. File Structure & Key Locations

```
/workspaces/PhantomZero613/
├── app.py                                 # Streamlit web UI
├── api_server.py                          # Flask API server (remote model)
├── mobile_app.py                          # Kivy mobile client
├── train_conversational_model.py          # Model training script
├── requirements.txt                       # Python dependencies
├── buildozer.spec                         # Android APK build config
│
├── Purple-Phantom.AI/
│   ├── Purple_Phantom.py                  # Core model + inference logic
│   ├── app.py                             # Duplicate Streamlit (for reference)
│   └── purple_phantom_conversational_model/
│       ├── pytorch_model.bin              # Trained GPT-2 weights
│       └── tokenizer.json
│
├── .devcontainer/
│   ├── devcontainer.json                  # Codespaces config
│   ├── Dockerfile                         # Container image build
│   ├── postCreateCommand.sh               # Setup script
│   └── start-novnc.sh                     # noVNC server launcher
│
└── Phantom_Zero[Code Files]/
    └── extra-fnf-opponent.lua             # Psych Engine Lua mods
```

---

## 7. Environment Variables

### Development (Local)
```bash
# Use local model only
unset REMOTE_API_URL

# Use remote API (Flask server)
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
```

### Production (Mobile/Web)
```bash
# Point to deployed API server
export REMOTE_API_URL="https://your-api-server.com/api/respond"
```

---

## 8. Common Tasks

### Task: Train, Test, Deploy to Mobile
```bash
# 1. Train model
python train_conversational_model.py

# 2. Test in Streamlit
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
streamlit run app.py
# (Manually test in browser)

# 3. Build APK
buildozer android debug

# 4. Transfer to device
adb install bin/purple_phantom-0.1-debug.apk
```

### Task: Develop FNF Content in Codespaces
```bash
# In Codespaces terminal
cd /home/codespace/fnf_workspace  # (if cloned)
haxe build.hxml
# Edit .lua files
# Compile and test
```

### Task: Fix Streamlit Import Errors
If you see `ModuleNotFoundError: tensorflow`:
- Already fixed! Both `app.py` files use `try/except` to make TensorFlow optional
- If needed, check [app.py](app.py#L1-L20) for optional imports pattern

---

## 9. Troubleshooting

| Issue | Solution |
|-------|----------|
| PowerShell not found | Run: `~/.local/pwsh/pwsh -v` to verify; or rebuild Codespaces container |
| Flask API not responding | Ensure port 8080 is not in use: `lsof -i :8080`; restart with `python api_server.py` |
| APK build fails (autoreconf) | Missing system toolchain; build on machine with Android SDK/NDK + autoconf/libtool |
| Model not found in API | Check `./purple_phantom_conversational_model/` exists; falls back to base GPT-2 if missing |
| Kivy mobile app crashes | Ensure `requests` is installed; set `REMOTE_API_URL` for proper API calls |
| Codespaces GUI (noVNC) not working | Rebuild container: **VS Code** → **Dev Containers: Rebuild Container** |

---

## 10. Next Steps

1. **Train Model:** Run `python train_conversational_model.py`
2. **Start API & Streamlit:** Use commands in Section 3
3. **Test Web UI:** Open http://localhost:8501 in browser
4. **Test Mobile:** Build APK and deploy (or use REMOTE_API_URL for testing)
5. **FNF Development:** Create GitHub Codespaces workspace for parallel FNF work
6. **Commit Changes:** `git add -A && git commit -m "Update model"`

---

## Quick Reference Commands

```bash
# Train model
python train_conversational_model.py

# Run API server
python api_server.py

# Run Streamlit with remote API
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
streamlit run app.py

# Build APK
buildozer android debug

# Test PowerShell
~/.local/pwsh/pwsh -v

# Access noVNC (Codespaces)
# Open: http://localhost:6080 (after port forwarding)
```

---

**Last Updated:** February 3, 2026
**Environment:** Ubuntu 24.04 LTS, Python 3.12, PowerShell 7.5.4
