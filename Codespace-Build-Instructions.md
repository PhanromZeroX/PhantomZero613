# 🚀 Instant Codespace Build Instructions

This guide provides **instant setup** for your complete development environment including:
- **Friday Night Funkin'** game development (Haxe/Lua)
- **Purple Phantom AI** assistant (Streamlit/Flask/TensorFlow)
- **Mobile app** support (Kivy)
- **GUI Desktop** via browser (noVNC)

---

## ⚡ Quick Start (2-3 minutes)

### Option 1: New Codespace (Recommended)
```bash
# 1. Go to: https://github.com/PhantomZero613-ai/PhantomZero613
# 2. Click "Code" → "Codespaces" → "Create codespace on main"
# 3. Wait for automatic setup (2-5 minutes)
# 4. All dependencies install automatically! ✓
```

### Option 2: Instant Manual Setup
```bash
# Clone and run instant setup
git clone https://github.com/PhantomZero613-ai/PhantomZero613.git
cd PhantomZero613
chmod +x instant-codespace-setup.sh
./instant-codespace-setup.sh
```

---

## 📦 What's Pre-Installed

### 🖥️ Development Tools
| Tool | Version | Purpose |
|------|---------|---------|
| **Haxe** | 4.3+ | FNF game language |
| **Lime/OpenFL** | Latest | Game framework |
| **Lua** | 5.4 | FNF modding |
| **PowerShell** | 7.x | Scripting |
| **Python** | 3.11+ | AI/Backend |

### 🤖 AI & Web Stack
| Package | Purpose |
|---------|---------|
| **Streamlit** | Web UI |
| **Flask** | API Server |
| **TensorFlow** | ML Framework |
| **Transformers** | GPT-2 Model |
| **Kivy** | Mobile App |
| **Pandas/Requests** | Data/IO |

### 🖼️ GUI Environment
- **XFCE Desktop** - Lightweight GUI
- **noVNC** - Browser-based desktop (port 6080)
- **x11vnc** - VNC Server

---

## 🎮 Start Commands

### AI Assistant (Web Interface)
```bash
# Terminal 1 - API Server
python api_server.py

# Terminal 2 - Web UI
python -m streamlit run app.py
```

**Access:** http://localhost:8501

### FNF Development (GUI Desktop)
```bash
# Start browser-based desktop
start-novnc.sh

# Access at: http://localhost:6080/vnc.html
# Password: vncpass
```

### Build FNF Games
```bash
cd PsychEngine
haxelib run lime build linux -debug
# or
haxe build.hxml
```

---

## 📱 Mobile App
```bash
python mobile_app.py
```

---

## 🔧 Manual Installation (if needed)

### Python Dependencies
```bash
python -m venv .venv
source .venv/bin/activate
pip install streamlit flask torch transformers requests kivy pandas
```

### Haxe Setup
```bash
# Haxe should auto-install from devcontainer
# Manual if needed:
sudo apt install haxe -y
haxelib install lime
haxelib install openfl
```

---

## 🐛 Troubleshooting

### Port Access Issues
```bash
# Check running services
netstat -tlnp | grep -E '8501|5000|6080'
```

### Python Environment
```bash
# Reactivate venv
source .venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

### noVNC/GUI
```bash
# Check noVNC status
ls -la /workspaces/PhantomZero613/.noVNC

# Restart GUI
start-novnc.sh
```

### Memory Issues
```bash
# Clear caches
pip cache purge
rm -rf ~/.cache/huggingface
```

---

## 📂 Key Files

| File | Purpose |
|------|---------|
| `app.py` | Main AI web interface |
| `api_server.py` | Flask API endpoint |
| `mobile_app.py` | Kivy mobile app |
| `start.sh` | Quick startup script |
| `instant-codespace-setup.sh` | One-command setup |
| `requirements.txt` | Python dependencies |

---

## 🎯 Daily Workflow

```bash
# 1. Open codespace
# 2. Start services:
./start.sh

# 3. Access:
# - Web UI: http://localhost:8501
# - API: http://localhost:5000
# - GUI: http://localhost:6080

# 4. Start coding! 🎉
```

---

## 💾 Storage Tips

- Codespaces: ~32GB limit
- Use **Git LFS** for large assets
- Keep dependencies minimal
- Push code frequently

---

## 🔗 Useful Links

- **Repository:** https://github.com/PhantomZero613-ai/PhantomZero613
- **PsychEngine Docs:** `PsychEngine/README.md`
- **Project Overview:** `README.md`
- **Quick Start:** `QUICK-START.md`

---

**✅ Setup Time: 2-5 minutes | Ready to code immediately!**

