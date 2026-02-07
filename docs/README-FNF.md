FNF Codespace Setup

- This devcontainer installs Haxe, haxelib, Lime and OpenFL and provides a lightweight XFCE desktop via noVNC on port 6080.
- After Codespace is created or devcontainer built, run `/usr/local/bin/start-novnc.sh` to start the desktop and access via the forwarded port.
- Common commands:

Start desktop (inside codespace):
```bash
start-novnc.sh
```

Install Psych Engine (example): follow upstream Psych Engine documentation — you will need to clone the repo and run `haxelib install ...` as directed.

Notes:
- Building Psych Engine and running heavy builds in Codespaces may require additional system packages and increased resources.
- Use the provided devcontainer as a starting point; adapt Dockerfile to add more libs as you discover missing dependencies.
