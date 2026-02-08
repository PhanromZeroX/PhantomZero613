# Psych Engine 1.0.4 - Setup Guide (Ubuntu 24.04 LTS)

## Quick Start (One-Time Setup)

### Step 1: Rebuild Container to Ubuntu 24.04
1. In VS Code: Press `Ctrl+Shift+P`
2. Type: **"Rebuild Container"**
3. Select: **"Rebuild Container"**
4. Wait 3-5 minutes for Ubuntu 24.04 installation

### Step 2: Run Psych Engine
After rebuild completes:
```bash
cd /workspaces/PhantomZero613/games/PsychEngine/export/release
./PsychEngine
```

Or use the script:
```bash
/workspaces/PhantomZero613/tools/build-and-run-psych.sh
```

---

## What's Pre-Installed (in devcontainer)

| Component | Version | Status |
|-----------|---------|--------|
| Ubuntu | 24.04 LTS | ✅ glibc 2.38+ |
| Haxe | 4.3.0 | ✅ Installed |
| Neko | 2.3.0 | ✅ Installed |
| Lime | 8.0.2 | ✅ Installed |
| OpenFL | 9.2.2 | ✅ Installed |
| Flixel | 5.6.1 | ✅ Installed |
| SDL2 Libraries | Latest | ✅ Installed |
| libvlc5 | Latest | ✅ Installed |

---

## Expected Behavior After Rebuild

✅ **Binary runs directly** - No compilation needed  
✅ **glibc 2.38** - Compatible with Psych Engine 1.0.4 binary  
✅ **Purple Phantom Mod** - Auto-detected in mods menu  
✅ **All assets** - Pre-loaded from `/games/PsychEngine/export/release/assets`  

---

## File Locations

| Path | Purpose |
|------|---------|
| `games/PsychEngine/export/release/PsychEngine` | Main executable |
| `games/PsychEngine/export/release/assets/` | Game data (songs, images) |
| `games/PsychEngine/mods/PurplePhantomMod/` | Custom mod |
| `tools/build-and-run-psych.sh` | Run script |
| `tools/build-psych-engine.sh` | Build from source (if needed) |

---

## Troubleshooting

**Problem:** Container won't rebuild
**Solution:** Delete codespace and create new one from GitHub

**Problem:** Binary won't start after rebuild
**Solution:** Run `chmod +x games/PsychEngine/export/release/PsychEngine`

**Problem:** Need to rebuild from source
**Solution:** Run `./tools/build-psych-engine.sh` (takes 10-20 min)

---

_Last Updated: 2026-02-07_

