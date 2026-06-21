Plan for Status Bar Item lifecycle (⚡ / ⏳ / ❌)

1) Gather: read PsychIDE/vscode-extension/extension.ts current LanguageClient integration status (it currently has only validators/watchers).
2) Decide wiring: add LanguageClient for psych_lsp.py if not present; then bind status bar state to LanguageClient lifecycle.
3) Implement:
   - Create status bar item: vscode.window.createStatusBarItem(Alignment.Left, 100)
   - Text states:
     A: ⏳ PsychIDE Initializing...
     B: ⚡ PsychIDE Active
     C: ❌ PsychIDE Stopped
   - Add command psychide.showOutput to reveal PsychIDE output channel/log.
   - Add language client event handlers:
     - set initializing before starting
     - onReady => active
     - onRequestError / onDidChangeState => stopped
     - catch spawn/stdio errors => stopped
4) Server integration: ensure extension spawns backend/psych_lsp.py as stdio process and passes correct env/working dir.
5) Update package.json contributes.commands for psychide.showOutput and maybe keep minimal.
6) Testing: run extension build (tsc) if possible; otherwise ensure TypeScript compiles.

Note: If LanguageClient is not currently used in extension.ts, we must add it to fully satisfy the lifecycle binding requirement.
