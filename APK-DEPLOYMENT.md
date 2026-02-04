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