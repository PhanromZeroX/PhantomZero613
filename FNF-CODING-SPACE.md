# FNF Coding Space Guide

## Quick Start: GitHub Codespaces for Friday Night Funkin' Development

Your FNF coding space (Codespaces devcontainer) provides a **complete game development environment** with:
- Haxe 4.3+ compiler
- Lime/OpenFL game framework  
- XFCE desktop GUI (accessible via browser at port 6080)
- Lua + Luarocks (for Psych Engine mods)
- PowerShell 7.5.4 terminal
- Python 3.12 (to train Purple Phantom models in parallel)

---

## What You Can Do in FNF Space

### 1. **Friday Night Funkin' (Psych Engine) Development**
- Compile Haxe code: `haxe build.hxml`
- Write/edit Lua mods: edit files in `/mods` folder
- Test game mods: run compiled builds
- Cross-compile to Windows/Linux/Web

### 2. **Train Purple Phantom Model (While Working on FNF)**
```bash
# Terminal 2 in Codespaces
cd /workspaces/PhantomZero613
python train_conversational_model.py
# ~5-15 minutes
```

### 3. **Update Mobile App with New Model**
```bash
# After training, build new APK:
export REMOTE_API_URL="https://your-api.com/api/respond"
buildozer android debug
```

### 4. **Run Streamlit Web UI for Testing**
```bash
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
streamlit run app.py
# Access at: http://localhost:8501
```

### 5. **GUI Desktop Workflow**
- Click **Ports** tab → open **port 6080** (noVNC)
- Full XFCE desktop in browser
- Launch terminal, IDE, or game testing directly in GUI

---

## Setup Codespaces (First Time)

1. **Go to Your Repo:**
   - Navigate to https://github.com/PhantomZero613-ai/PhantomZero613

2. **Create Codespace:**
   - Click **<> Code** → **Codespaces** → **Create codespace on main**
   - Wait ~3–5 minutes for container to build

3. **Rebuild Container (to Install Tools):**
   - Once VS Code opens in browser
   - Press **F1** → search **"Rebuild Container"** → Enter
   - Wait for rebuild to complete (this installs pwsh, lua, Haxe, etc.)

4. **Access GUI (Optional):**
   - Click **Ports** tab in VS Code
   - Find port **6080** → click URL or **"Open in Browser"**
   - XFCE desktop opens in new tab (ready for game dev)

---

## Development Commands

### Haxe/Lime (FNF Compilation)
```bash
# Build for Linux (debug)
lime build linux -debug

# Build for Windows (release)
lime build windows -D release

# Clean build
lime clean
haxe build.hxml

# Test with Haxe directly
haxe -main Test -js test.js
node test.js
```

### Lua (Psych Engine Mods)
```bash
# Navigate to mods folder
cd mods/

# Edit a mod
nano my_mod.lua

# Test/load mod in Psych Engine
lua my_mod.lua
```

### Purple Phantom (Model Training)
```bash
# Train new conversational model
cd /workspaces/PhantomZero613
python train_conversational_model.py

# Verify model works
python api_server.py          # Terminal 2
streamlit run app.py           # Terminal 3 (with REMOTE_API_URL set)
```

### PowerShell Scripting
```bash
# Switch to PowerShell terminal in Codespaces
pwsh

# Run PowerShell script
Write-Host "Hello from PowerShell in Codespaces!"

# Exit
exit
```

---

## Multi-Terminal Workflow Example

You have **multiple terminals** in Codespaces to work on FNF + AI in parallel:

**Terminal 1 (FNF Development):**
```bash
haxe build.hxml
# Compile and monitor for changes
```

**Terminal 2 (Model Training):**
```bash
cd /workspaces/PhantomZero613
python train_conversational_model.py
```

**Terminal 3 (API Server):**
```bash
cd /workspaces/PhantomZero613
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
python api_server.py
```

**Terminal 4 (Streamlit UI):**
```bash
cd /workspaces/PhantomZero613
streamlit run app.py
```

All running simultaneously—work on FNF while training models!

---

## File Structure in Codespaces

After first setup:
```
/workspaces/PhantomZero613/
├── app.py                           # Streamlit UI
├── api_server.py                    # Flask API
├── mobile_app.py                    # Kivy mobile
├── train_conversational_model.py    # Model trainer
├── buildozer.spec                   # APK config
├── Purple-Phantom.AI/               # Core model
└── Phantom_Zero[Code Files]/
    └── extra-fnf-opponent.lua       # FNF mods
```

---

## Port Forwarding (Codespaces)

Ports automatically forward to your browser:
- **8501** → Streamlit web UI
- **8080** → Flask API server
- **6080** → noVNC GUI desktop
- **5900** → VNC raw protocol

Just click the port in the **Ports** tab to open in browser!

---

## Rebuild Container (If Tools Missing)

If PowerShell, Lua, or Haxe aren't available:

1. Press **F1** in VS Code
2. Search: **"Dev Containers: Rebuild Container"**
3. Click and wait for rebuild (~2–5 min)
4. All tools will be installed from Dockerfile

---

## Common Workflows

### Workflow 1: Develop FNF + Test Purple Phantom in Parallel
```bash
# Terminal 1: Compile FNF
haxe build.hxml

# Terminal 2: Train new model
python train_conversational_model.py

# Terminal 3: Start API + Streamlit
python api_server.py & export REMOTE_API_URL="http://127.0.0.1:8080/api/respond" && streamlit run app.py
```

### Workflow 2: Update Mobile App After Model Training
```bash
# After training completes (Terminal 2)
# Build new APK with updated model:
buildozer android debug

# Transfer to Android device:
adb install bin/purple_phantom-0.1-debug.apk
```

### Workflow 3: Quick Model Test in Web UI
```bash
# Run API server + Streamlit:
python api_server.py &
export REMOTE_API_URL="http://127.0.0.1:8080/api/respond"
streamlit run app.py

# Browser: http://localhost:8501
# Test new model interactively!
```

---

## Troubleshooting Codespaces

| Problem | Solution |
|---------|----------|
| Tools not installed (haxe, lua, pwsh) | Rebuild container: F1 → "Rebuild Container" |
| Port 6080 not forwarding | Refresh VS Code ports panel; rebuild if needed |
| PowerShell command not found | Rebuild container; pwsh should be in PATH after |
| Model training slow | Normal; run in background Terminal 2 while working on FNF in Terminal 1 |
| Flask API not responding | Check port 8080: curl http://localhost:8080/api/respond |

---

## Next Steps

1. **Create GitHub Codespace** (click Code → Codespaces)
2. **Rebuild Container** (F1 → Rebuild Container)
3. **Open Ports Panel** (view noVNC, Streamlit, Flask)
4. **Develop!**
   - FNF: `haxe build.hxml`
   - Model: `python train_conversational_model.py`
   - Test: `streamlit run app.py`

---

**Your FNF Coding Space is Ready!** 🚀

All tools (Haxe, Lime, Lua, Python, PowerShell, GUI) are pre-configured in the devcontainer.
Just create a Codespace and start developing.

