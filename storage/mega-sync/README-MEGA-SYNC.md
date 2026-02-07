# 🌩️ Mega.nz Cloud Storage Integration

This directory contains utilities to sync your game mods, saves, and assets with **Mega.nz** cloud storage (free 50GB tier).

## 📋 Quick Start

### Option 1: Interactive Menu (Easiest)
```bash
cd /workspaces/PhantomZero613/tools
bash mega-sync.sh
```

This opens an interactive menu where you can:
- Setup your Mega.nz account
- Download files
- Upload files
- View storage status

### Option 2: Python Script
```bash
cd /workspaces/PhantomZero613/storage/mega-sync
python3 mega-download.py          # Download from Mega.nz
python3 mega-upload.py            # Upload to Mega.nz
```

### Option 3: Command Line

First-time setup:
```bash
export MEGA_EMAIL="your-email@example.com"
export MEGA_PASSWORD="your-password"
```

Then use in Python or shell scripts.

---

## 🔐 Setup Guide

### Step 1: Create Mega.nz Account
1. Visit https://mega.nz/
2. Sign up (free 50GB storage tier)
3. Confirm your email

### Step 2: Configure Codespace
```bash
cd /workspaces/PhantomZero613/tools
bash mega-sync.sh
# Choose option 1 (Setup Account)
# Enter your Mega.nz email and password
```

Configuration is saved to: `../storage/mega-sync/.mega_config` (permissions: 600, readable only by you)

### Step 3: Test Connection
```bash
bash mega-sync.sh
# Choose option 4 (View Status)
```

You should see your account details and storage size.

---

## 📤 Upload Mods to Mega.nz

### Method 1: Via Menu
```bash
bash mega-sync.sh
# Choose option 3 (Upload Files)
```

### Method 2: Drag & Drop (Web)
1. Go to https://mega.nz/ and log in
2. Create a folder named `PhantomZero-Mods`
3. Drag mod files directly into your Mega.nz web interface

### Method 3: Python Script
```bash
cd /workspaces/PhantomZero613/storage/mega-sync
python3 << 'EOF'
from mega import Mega
import os

mega = Mega()
m = mega.login(os.environ['MEGA_EMAIL'], os.environ['MEGA_PASSWORD'])

# Create folder
folder = m.create_folder('PhantomZero-Mods')

# Upload file
m.upload('path/to/mod.zip', folder[0])
print("✅ Uploaded!")
EOF
```

---

## 📥 Download Mods from Mega.nz

### Method 1: Via Menu
```bash
bash mega-sync.sh
# Choose option 2 (Download Files)
```

### Method 2: Python Script
```bash
cd /workspaces/PhantomZero613/storage/mega-sync
python3 << 'EOF'
from mega import Mega
import os

mega = Mega()
m = mega.login(os.environ['MEGA_EMAIL'], os.environ['MEGA_PASSWORD'])

# List all files
files = m.get_files()
for file_id in files:
    m.download(file_id, '.')
    print(f"✅ Downloaded: {files[file_id]}")
EOF
```

---

## 🎮 Auto-Sync Mods to Psych Engine

Create a cron job or scheduled task:

```bash
# Create auto-sync script
cat > /workspaces/PhantomZero613/tools/auto-sync-mods.sh << 'SCRIPT'
#!/bin/bash
# Auto-sync mods from Mega.nz to Psych Engine

VENV="/workspaces/PhantomZero613/.venv-1/bin/activate"
source $VENV

python3 << 'PYTHON'
from mega import Mega
import os
import shutil
from datetime import datetime

mega = Mega()
m = mega.login(os.environ['MEGA_EMAIL'], os.environ['MEGA_PASSWORD'])

download_dir = "/workspaces/PhantomZero613/storage/mega-sync/downloads"
os.makedirs(download_dir, exist_ok=True)

# Download mod folders
files = m.get_files()
print(f"[{datetime.now()}] Syncing {len(files)} file(s)...")

for file_id, file_info in files.items():
    if 'Mod' in file_info.get('a', {}).get('n', ''):
        m.download(file_id, download_dir)
        print(f"  ✅ Synced {file_info['a']['n']}")

# Copy to Psych Engine mods
mods_dir = "/workspaces/PhantomZero613/games/PsychEngine/mods"
for mod in os.listdir(download_dir):
    src = os.path.join(download_dir, mod)
    dst = os.path.join(mods_dir, mod)
    if os.path.isdir(src):
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.move(src, dst)
        print(f"  📁 Copied to Psych Engine: {mod}")

print(f"[{datetime.now()}] Sync complete!")
PYTHON
SCRIPT

chmod +x /workspaces/PhantomZero613/tools/auto-sync-mods.sh
```

Run daily:
```bash
# Add to crontab (run daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /workspaces/PhantomZero613/tools/auto-sync-mods.sh") | crontab -
```

---

## 📊 Storage Organization

Recommended Mega.nz folder structure:

```
Mega.nz Root
├── PhantomZero-Mods/
│   ├── Custom-Mod-1/
│   ├── Custom-Mod-2/
│   └── Mod-Assets/
├── Saves/
│   ├── fnf-saves.zip
│   └── ai-model-backup.zip
└── Backups/
    ├── project-backup-2026-02.zip
    └── purple-phantom-ai-backup.zip
```

Local structure mirrors this in:
```
/workspaces/PhantomZero613/storage/mega-sync/
├── downloads/          # Downloaded files
├── uploads/            # Ready to upload
└── .mega_config        # Configuration (keep private!)
```

---

## 🔑 Security Notes

⚠️ **Important**: Never commit `.mega_config` to GitHub!

Already protected:
- `.mega_config` is in `.gitignore` by default
- File permissions set to 600 (only readable by you)
- Credentials never logged to console

Best practices:
- Use strong, unique Mega.nz password
- Don't share recovery codes
- Enable 2FA on Mega.nz account if available
- Keep `.mega_config` permissions restricted

---

## 🐛 Troubleshooting

### "Connection failed"
```bash
# Check internet connection
ping mega.nz

# Test credentials
python3 << 'EOF'
from mega import Mega
try:
    m = Mega().login("email", "password")
    print("✅ Login successful!")
except:
    print("❌ Login failed - check credentials")
EOF
```

### "mega.py not found"
```bash
source /workspaces/PhantomZero613/.venv-1/bin/activate
pip install mega.py
```

### "Slow download speeds"
- Mega.nz has bandwidth throttling on free accounts
- Try downloading during off-peak hours
- Break large uploads into smaller files

### Script hangs on upload
- Mega.nz connections may time out
- Try smaller file sizes (<500MB)
- Use web interface for very large files

---

## 📚 Resources

- **Mega.nz Home**: https://mega.nz/
- **mega.py Docs**: https://python-mega.readthedocs.io/
- **MegaCmd**: https://github.com/meganz/MEGAcmd (alternative CLI tool)
- **API Reference**: https://github.com/meganz/sdk3_python

---

## 💾 Backup Strategy

### Weekly Backups
```bash
# Create backup script
cat > /workspaces/PhantomZero613/tools/backup-to-mega.sh << 'BACKUP'
#!/bin/bash
BACKUP_FILE="/workspaces/PhantomZero613/storage/mega-sync/backup-$(date +%Y-%m-%d).zip"
cd /workspaces/PhantomZero613/games/PsychEngine/mods
zip -r $BACKUP_FILE PurplePhantomMod/
python3 << 'PYTHON'
from mega import Mega
import os
mega = Mega().login(os.environ['MEGA_EMAIL'], os.environ['MEGA_PASSWORD'])
mega.upload(open(mega, 'rb'))
PYTHON
BACKUP

chmod +x /workspaces/PhantomZero613/tools/backup-to-mega.sh
```

Schedule:
```bash
# Daily at 3 AM
(crontab -l 2>/dev/null; echo "0 3 * * * /workspaces/PhantomZero613/tools/backup-to-mega.sh") | crontab -
```

---

## ✨ Features

- ✅ Free 50GB cloud storage
- ✅ End-to-end encryption (Mega.nz feature)
- ✅ Works on all platforms (Python-based)
- ✅ Interactive menu system
- ✅ Python API for automation
- ✅ Automatic mod syncing
- ✅ Backup scheduling
- ✅ Version history (via Mega.nz web)

---

## 🎯 Next Steps

1. **First time?** Run `bash mega-sync.sh` and choose option 1 (Setup)
2. **Have files?** Use option 3 (Upload)
3. **Want mods?** Use option 2 (Download) or the web interface
4. **Auto-sync?** Create a cron job using the backup script above
5. **More features?** Check `docs/` for complete guides

---

*Mega.nz Integration for Purple Phantom AI - Last Updated: Feb 7, 2026*
