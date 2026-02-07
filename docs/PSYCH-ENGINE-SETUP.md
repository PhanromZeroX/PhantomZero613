# Psych Engine 1.0.4 Setup Guide for Codespace

## Status Summary

### ✅ Completed Tasks
1. **VS Code Extensions Installed:**
   - Python extension (ms-python.python)
   - Lua Helper extension (yinfei.luahelper)
   - BLACKBOX AI extension (blackboxapp.blackbox)
   - BLACKBOX AI Agent extension (blackboxapp.blackboxagent)

2. **Python Environment Setup:**
   - Python 3.12.12 venv created
   - Core libraries installed: streamlit, pandas, requests, flask, numpy, pillow, pyarrow

3. **Storage Verification:**
   - ❌ mega.nz (Union Free Extended Storage) is NOT available in this codespace
   - The /tmp filesystem is available for temporary storage
   - Alternative: Use standard Codespace storage or clone from GitHub

---

## Psych Engine 1.0.4 Installation Steps

### Prerequisites
Psych Engine requires:
- Haxe compiler (4.0+)
- Neko virtual machine
- OpenFL framework
- haxelib package manager
- Git

### Installation Method A: Docker/Container (Recommended for Alpine Linux)

Since Haxe binaries are not available in Alpine repositories, use a pre-built Haxe Docker image:

```bash
# Option 1: Using official Haxe image (if Docker is available)
docker pull haxe:4.3.0-alpine
docker run -it --rm -v /workspaces/PhantomZero613:/workspace haxe:4.3.0-alpine
```

### Installation Method B: Manual Setup (Advanced)

```bash
# 1. Download Haxe from GitHub releases
cd /tmp
wget https://github.com/HaxeFoundation/haxe/releases/download/4.3.0/haxe-4.3.0-linux64.tar.gz
tar -xzf haxe-4.3.0-linux64.tar.gz

# 2. Setup PATH
export HAXE_PATH="/tmp/haxe_20230405165950_731dcd7"
export PATH="$HAXE_PATH:$PATH"

# 3. Clone Psych Engine 1.0.4
cd /workspaces/PhantomZero613
git clone --branch v1.0.4 https://github.com/ShadowMario/FNF-PsychEngine.git PsychEngine

cd PsychEngine

# 4. Install haxelib dependencies
haxelib newrepo
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec
haxelib install lime 7.9.0
haxelib install openfl 9.0.2
haxelib install hxcpp
haxelib install format
haxelib install actuate
haxelib install extension-webm
haxelib git linc_luajit https://github.com/nebkor/linc_luajit

# 5. Build the project
lime build linux
```

### Installation Method C: Using Web-Based Build Service

Visit: https://build.haxe.org/ (if available) for cloud compilation

---

## Project Structure After Installation

```
/workspaces/PhantomZero613/
├── PsychEngine/           # Main Psych Engine source
│   ├── source/           # Haxe source code
│   ├── assets/           # Game assets (songs, images, data)
│   ├── export/           # Build output directory
│   └── project.xml       # Lime project configuration
├── app.py                # Purple Phantom AI chatbot (Streamlit)
├── train_conversational_model.py  # AI training script
└── mobile_app.py         # Mobile interface (Kivy)
```

---

## Making Psych Engine Playable & Modable

### 1. Building the Game
```bash
cd /workspaces/PhantomZero613/PsychEngine

# Build for Linux (native compilation)
lime build linux -debug

# Build for web (HTML5)
lime build html5

# Run the game
./export/linux/bin/FNF  # Linux binary
```

### 2. Modding Structure

Psych Engine supports modding through:

**a) Custom Charts:**
- Location: `PsychEngine/assets/songs/[songname]/`
- Formats: `.json` (chart data), `.ogg` (audio)

**b) Custom Scripts (Lua):**
- Location: `PsychEngine/assets/scripts/` or `PsychEngine/assets/data/[storyname]/`
- File: `script.lua` or `[eventname].lua`
- Hooks available:
  ```lua
  function onCreate() end          -- Initialize
  function onCreatePost() end      -- Post-initialize
  function update(elapsed) end     -- Every frame
  function onStepHit() end         -- Rhythm step
  function onBeatHit() end         -- Beat trigger
  function onCountdownTick() end   -- Countdown tick
  ```

**c) Character/Stage Definitions:**
- JSON files in: `PsychEngine/assets/data/[storyname]/`
- Examples: `characters.json`, `stages.json`

### 3. Development Workflow

```bash
# 1. Create mods directory
mkdir -p /workspaces/PhantomZero613/PsychEngine/mods/MyMod/

# 2. Create mod structure
mkdir -p /workspaces/PhantomZero613/PsychEngine/mods/MyMod/{characters,stages,songs,scripts}

# 3. Create mod.json configuration
cat > /workspaces/PhantomZero613/PsychEngine/mods/MyMod/mod.json << 'EOF'
{
  "name": "My Custom Mod",
  "description": "A custom Psych Engine mod",
  "author": "Your Name",
  "version": "1.0.0"
}
EOF

# 4. Add custom scripts, characters, stages
# (See examples in main assets directory)

# 5. Test mod by building and running
cd /workspaces/PhantomZero613/PsychEngine
lime build linux -debug
./export/linux/bin/FNF
```

### 4. Integration with Purple Phantom AI

You can integrate the AI chatbot with Psych Engine dialogs:

```lua
-- In PsychEngine event script or character script
function onDialogueStart()
    callOnLua("getAIResponse", player.name, function(response)
        showDialogue(response)
    end)
end
```

Then connect via HTTP:
```haxe
// In Haxe code
var http = new haxe.Http("http://127.0.0.1:5000/api/respond");
http.onData = function(data) {
    var response = haxe.Json.parse(data);
    dialogue = response.response;
};
http.request();
```

---

## Troubleshooting

### Build Errors

**"haxe: not found"**
- Ensure Haxe is in PATH: `export PATH="/tmp/haxe_dir:$PATH"`
- Verify installation: `haxe --version`

**"Library X not found" (haxelib errors)**
- Reinstall library: `haxelib install [libname]`
- Check installed: `haxelib list`

**"Cannot execute binary file"**
- Alpine Linux binary compatibility issue
- Solution: Use Docker container or compile from source

### Runtime Issues

**Game won't start**
- Check OpenGL support: `glxinfo` (may not work in headless environments)
- Try with software rendering: `LIBGL_ALWAYS_INDIRECT=1 ./FNF`

**Audio issues**
- Ensure multimedia libraries installed
- Install ffmpeg if needed: `apt-get install ffmpeg`

---

## Alternative: Using Windows/Mac Build

If Linux compilation fails, you can:
1. Build on Windows/Mac locally
2. Push binary to repo
3. Commit compiled `export/linux/bin/FNF` to git
4. Run precompiled binary in codespace

---

## Next Steps

1. Choose installation method (A, B, or C above)
2. Run build and test
3. Create `mods/` directory
4. Start developing custom content
5. Integrate with Purple Phantom AI chatbot if desired

## Resources

- **Psych Engine Repo**: https://github.com/ShadowMario/FNF-PsychEngine
- **Haxe Documentation**: https://haxe.org/documentation/
- **Lime/OpenFL Docs**: https://lime.openfl.org/
- **Modding Guide**: https://github.com/ShadowMario/FNF-PsychEngine/wiki

---

Generated: 2/7/2026
Codespace: Alpine Linux v3.23
Python: 3.12.12 ✓
Extensions: Python, Lua, Blackbox AI ✓
