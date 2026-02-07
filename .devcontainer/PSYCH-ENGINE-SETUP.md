# Psych Engine 1.0.4 Setup for Codespaces

## Current Status

✅ **Binary Ready**: Pre-built Psych Engine 1.0.4 Linux executable downloaded and available at:
```
games/PsychEngine/export/release/PsychEngine
```

## Container Environment Requirements

The pre-built binary requires:
- **Base OS**: Ubuntu 22.04 (with glibc)
- **Key Libraries**: libvlc5, libvlccore9, and audio libraries
- **Display**: X11 + VNC (for graphical output in Codespaces)

### Current Container: Alpine Linux

The **current** running container is **Alpine Linux v3.23** (uses musl libc), which is **incompatible** with the glibc-compiled binary.

### Next Codespace: Ubuntu 22.04

When you create a **new Codespace**, the updated `.devcontainer/Dockerfile` will:
1. Use `ubuntu-22.04` as the base image
2. Install libvlc5, libvlccore9, vlc-data
3. Install graphics libraries (X11, VNC)
4. Pre-install all required dependencies

The binary will run immediately in the new Codespace.

## Quick Start (After Rebuilding to Ubuntu)

```bash
# Run from workspace root
./tools/build-and-run-psych.sh

# Or run directly
./games/PsychEngine/export/release/PsychEngine
```

## Instructions for Current Session

### Option 1: Rebuild This Codespace (Recommended if testing immediately)

In VS Code command palette:
1. `Ctrl+Shift+P` → "Rebuild Container"
2. Wait ~3–5 minutes for Ubuntu 22.04 to build
3. Binary will be ready to run

### Option 2: Continue with Alpine (Limited)

- Purple Phantom AI code and development continues normally
- Psych Engine binary cannot run in Alpine
- Mod development works (folder structure ready in `games/PsychEngine/mods/PurplePhantomMod/`)

### Option 3: Create a New Codespace

- New Codespaces automatically use the updated Dockerfile
- Binary and all dependencies pre-installed
- Recommended for future development sessions

## Troubleshooting

If the binary still won't run after rebuilding to Ubuntu:

1. Verify the binary is executable:
   ```bash
   ls -lh games/PsychEngine/export/release/PsychEngine
   chmod +x games/PsychEngine/export/release/PsychEngine
   ```

2. Check library availability:
   ```bash
   ldd games/PsychEngine/export/release/PsychEngine
   ```

3. Try running with verbose output:
   ```bash
   ./games/PsychEngine/export/release/PsychEngine 2>&1
   ```

## Modding in Parallel

Even in Alpine, you can prepare mods:

- **Template**: `games/PsychEngine/mods/PurplePhantomMod/`
- **Add Assets**: Place character PNGs in `assets/images/characters/`
- **Add Songs**: Place chart files in `data/` and audio in `assets/sounds/music/`
- Full folder structure is ready for GameBanana-style mods

When you rebuild to Ubuntu and run the binary, any mods in `mods/` will load automatically.

## Dockerfile Changes

Updated `.devcontainer/Dockerfile` now includes:
```dockerfile
libvlc5 libvlccore9 vlc-data \
libpulse0 libogg0 libflac8 libvorbis0a libvorbisfile3
```

These packages enable audio/video playback in the binary.

## File Locations

- **Binary**: `games/PsychEngine/export/release/PsychEngine` (51M)
- **Launcher**: `tools/build-and-run-psych.sh`
- **Mod Template**: `games/PsychEngine/mods/PurplePhantomMod/`
- **Assets**: `games/PsychEngine/export/release/assets/`
- **Configuration**: `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`

## Next Steps

1. **Now**: Continue Purple Phantom AI development and mod preparation
2. **When Ready**: Rebuild container to Ubuntu 22.04
3. **Then**: Test Psych Engine binary and mod loading
4. **Final**: Commit changes to git

See `docs/DEVELOPMENT-WORKFLOWS.md` for general development workflows.
