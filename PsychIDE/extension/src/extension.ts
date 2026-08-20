import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions,
    TransportKind,
} from 'vscode-languageclient/node';
import { checkGameConnection, sendCommandToGame } from './debuggerBridge';

function createPsychServerOptions(extensionPath: string): ServerOptions {
    const serverPath = path.join(
        extensionPath,
        'backend',
        'psych_lsp.py'
    );

    // We use stdio transport: VS Code connects stdin/stdout of the python process.
    return {
        command: 'python3',
        args: [serverPath],
    };
}

let diagnosticCollection: vscode.DiagnosticCollection;

type PsychIDEStatus = 'initializing' | 'active' | 'stopped';

let statusBarItem: vscode.StatusBarItem | undefined;
let psychClient: LanguageClient | undefined;
const aiKeySecretName = 'psychIde.geminiApiKey';

async function sendStoredAiKey(secrets: vscode.SecretStorage): Promise<void> {
    if (!psychClient) return;
    const apiKey = await secrets.get(aiKeySecretName);
    await psychClient.sendRequest('psychIde/configureAiKey', { apiKey: apiKey || '' });
}

async function configureAiKey(context: vscode.ExtensionContext, openSetupTerminal: boolean): Promise<boolean> {
    if (!psychClient) {
        vscode.window.showErrorMessage('PsychIDE language server is not active.');
        return false;
    }

    if (openSetupTerminal) {
        const shellPath = process.platform === 'win32' ? 'powershell.exe' : 'pwsh';
        const terminal = vscode.window.createTerminal({ name: 'PsychIDE AI Setup', shellPath });
        terminal.show(true);
        terminal.sendText('Write-Host "PsychIDE AI setup: create a Gemini API key, then paste it into VS Code."');
        terminal.sendText('Write-Host "The key is stored in VS Code Secret Storage, not in this terminal or the project."');
    }

    await vscode.env.openExternal(vscode.Uri.parse('https://aistudio.google.com/app/apikey'));
    const apiKey = await vscode.window.showInputBox({
        prompt: 'Paste your Gemini API key from Google AI Studio',
        password: true,
        ignoreFocusOut: true,
        validateInput: value => value.trim() ? undefined : 'An API key is required.',
    });
    if (!apiKey) return false;

    await context.secrets.store(aiKeySecretName, apiKey.trim());
    await psychClient.sendRequest('psychIde/configureAiKey', { apiKey: apiKey.trim() });
    vscode.window.showInformationMessage('PsychIDE AI API key configured securely.');
    return true;
}

function setStatus(status: PsychIDEStatus) {
    if (!statusBarItem) return;

    switch (status) {
        case 'initializing':
            statusBarItem.text = '⏳ PsychIDE Initializing...';
            statusBarItem.color = undefined;
            statusBarItem.backgroundColor = undefined;
            statusBarItem.command = 'psychide.showOutput';
            statusBarItem.show();
            return;
        case 'active':
            statusBarItem.text = '⚡ PsychIDE Active';
            statusBarItem.color = undefined;
            statusBarItem.backgroundColor = undefined;
            statusBarItem.command = 'psychide.showOutput';
            statusBarItem.show();
            return;
        case 'stopped':
            statusBarItem.text = '❌ PsychIDE Stopped';
            statusBarItem.color = new vscode.ThemeColor('statusBarItem.errorForeground');
            statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.errorBackground');
            statusBarItem.command = 'psychide.showOutput';
            statusBarItem.show();
            return;
    }
}

export async function activate(context: vscode.ExtensionContext) {
    diagnosticCollection = vscode.languages.createDiagnosticCollection('psych-ide');
    context.subscriptions.push(diagnosticCollection);

    const output = vscode.window.createOutputChannel('PsychIDE');
    context.subscriptions.push(output);

    // Status bar heartbeat
    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    statusBarItem.command = 'psychide.showOutput';
    statusBarItem.tooltip = 'PsychIDE server status';
    statusBarItem.show();
    setStatus('initializing');
    context.subscriptions.push(statusBarItem);

    context.subscriptions.push(
        vscode.commands.registerCommand('psychide.showOutput', () => {
            output.show(true);
        })
    );

    output.appendLine('Psych Engine IDE activated');

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.reloadScript', async () => {
            const host = vscode.workspace.getConfiguration('psychIde.debug').get<string>('host', '127.0.0.1');
            const port = vscode.workspace.getConfiguration('psychIde.debug').get<number>('port', 8000);
            try {
                await sendCommandToGame('reload_script', host, port);
                vscode.window.showInformationMessage('Psych Engine script reload requested.');
            } catch (error) {
                const message = error instanceof Error ? error.message : String(error);
                vscode.window.showErrorMessage(`PsychIDE hot reload failed: ${message}`);
            }
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.checkGameConnection', async () => {
            const host = vscode.workspace.getConfiguration('psychIde.debug').get<string>('host', '127.0.0.1');
            const port = vscode.workspace.getConfiguration('psychIde.debug').get<number>('port', 8000);
            try {
                await checkGameConnection(host, port);
                vscode.window.showInformationMessage(`Psych Engine debug server is reachable at ${host}:${port}.`);
            } catch (error) {
                const message = error instanceof Error ? error.message : String(error);
                vscode.window.showErrorMessage(`PsychIDE connection check failed: ${message}`);
            }
        })
    );

    // --- IGNITION CODE ---
    try {
        const clientOptions: LanguageClientOptions = {
            documentSelector: [
                { scheme: 'file', language: 'lua' },
                { scheme: 'file', language: 'haxe' },
                { scheme: 'file', language: 'json' }
            ]
        };

        const serverOptions = createPsychServerOptions(context.extensionPath);

        psychClient = new LanguageClient(
            'psychLSP',
            'Psych Engine Language Server',
            serverOptions,
            clientOptions
        );

        await new Promise(resolve => setTimeout(resolve, 1500)); 
        await psychClient.start();
        await sendStoredAiKey(context.secrets);
        
        setStatus('active');
        output.appendLine('PsychIDE Language Server successfully attached! 🚀');
    } catch (error) {
        setStatus('stopped');
        output.appendLine(`Failed to start PsychIDE Language Server: ${error}`);
    }

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.configureAiKey', async () => {
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }
            const action = await vscode.window.showQuickPick(
                ['Set or replace Gemini API key', 'Clear stored Gemini API key', 'Open Google AI Studio'],
                { placeHolder: 'Configure PsychIDE AI access' }
            );
            if (action === 'Open Google AI Studio') {
                await vscode.env.openExternal(vscode.Uri.parse('https://aistudio.google.com/app/apikey'));
                return;
            }
            if (action === 'Clear stored Gemini API key') {
                await context.secrets.delete(aiKeySecretName);
                await psychClient.sendRequest('psychIde/configureAiKey', { apiKey: '' });
                vscode.window.showInformationMessage('PsychIDE AI API key cleared.');
                return;
            }
            if (action === 'Set or replace Gemini API key') {
                await configureAiKey(context, true);
            }
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.reindexWorkspace', async () => {
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }
            const result = await psychClient.sendRequest('psychIde/reindexWorkspace', {}) as {
                documents?: number;
                symbols?: number;
                apiFunctions?: number;
                apiCallbacks?: number;
            };
            vscode.window.showInformationMessage(
                `PsychIDE reindexed ${result.documents || 0} documents, ${result.symbols || 0} symbols, ` +
                `${result.apiFunctions || 0} functions, and ${result.apiCallbacks || 0} callbacks.`
            );
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.resizeSpriteSheet', async () => {
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }

            const activeEditor = vscode.window.activeTextEditor;
            const defaultUri = activeEditor && activeEditor.document.uri.fsPath.toLowerCase().endsWith('.png')
                ? activeEditor.document.uri
                : undefined;

            const imageUri = await vscode.window.showOpenDialog({
                canSelectFiles: true,
                canSelectFolders: false,
                canSelectMany: false,
                filters: { 'Sprite sheets': ['png'] },
                defaultUri,
                openLabel: 'Select sprite sheet',
            });

            if (!imageUri || imageUri.length === 0) {
                return;
            }

            const profile = await pickExportProfile();
            if (!profile) {
                return;
            }

            const imagePath = imageUri[0].fsPath;
            const folder = path.dirname(imagePath);
            const baseName = path.basename(imagePath, path.extname(imagePath));
            const outputFolder = path.join(folder, 'psychide-resized', profile.id);
            const outputImagePath = path.join(outputFolder, `${baseName}_${profile.id}${path.extname(imagePath)}`);
            const xmlPath = fs.existsSync(path.join(folder, `${baseName}.xml`))
                ? path.join(folder, `${baseName}.xml`)
                : undefined;
            const jsonCandidates = fs.existsSync(folder)
                ? fs.readdirSync(folder)
                    .filter(file => file.startsWith(baseName) && file.endsWith('.json'))
                    .map(file => path.join(folder, file))
                : [];
                const outputXmlPath = xmlPath ? path.join(outputFolder, `${baseName}_${profile.id}.xml`) : undefined;
                const outputJsonPaths = jsonCandidates.map(file =>
                    path.join(outputFolder, `${path.basename(file, '.json')}_${profile.id}.json`)
                );

            const result = await psychClient.sendRequest('psychIde/resizeSpriteSheet', {
                imagePath,
                    targetWidth: profile.width,
                xmlPath,
                jsonPaths: jsonCandidates,
                    outputImagePath,
                    outputXmlPath,
                    outputJsonPaths,
                overwrite: false,
            }) as { ok?: boolean; error?: string; new_size?: number[]; scale?: number };

            if (!result.ok) {
                vscode.window.showErrorMessage(`Sprite resize failed: ${result.error || 'Unknown error'}`);
                return;
            }

            vscode.window.showInformationMessage(
                `${profile.label} export created: ${result.new_size ? result.new_size.join('x') : 'unknown size'}.`
            );
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.resizeSpriteFolder', async () => {
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }

            const folderUri = await vscode.window.showOpenDialog({
                canSelectFiles: false,
                canSelectFolders: true,
                canSelectMany: false,
                openLabel: 'Select sprite folder',
            });

            if (!folderUri || folderUri.length === 0) {
                return;
            }

            const profile = await pickExportProfile();
            if (!profile) {
                return;
            }

            const folderPath = folderUri[0].fsPath;
            const outputRoot = path.join(folderPath, 'psychide-resized', profile.id);
            const imageFiles = findImageFiles(folderPath, outputRoot);

            const results: string[] = [];
            for (const imagePath of imageFiles) {
                const relativeFolder = path.relative(folderPath, path.dirname(imagePath));
                const outputFolder = path.join(outputRoot, relativeFolder);
                const baseName = path.basename(imagePath, path.extname(imagePath));
                const sourceFolder = path.dirname(imagePath);
                const outputImagePath = path.join(outputFolder, `${baseName}_${profile.id}${path.extname(imagePath)}`);
                const xmlPath = fs.existsSync(path.join(sourceFolder, `${baseName}.xml`))
                    ? path.join(sourceFolder, `${baseName}.xml`)
                    : undefined;
                const jsonCandidates = fs.readdirSync(sourceFolder)
                    .filter(file => file.startsWith(baseName) && file.endsWith('.json'))
                    .map(file => path.join(sourceFolder, file));
                const outputXmlPath = xmlPath ? path.join(outputFolder, `${baseName}_${profile.id}.xml`) : undefined;
                const outputJsonPaths = jsonCandidates.map(file =>
                    path.join(outputFolder, `${path.basename(file, '.json')}_${profile.id}.json`)
                );

                const result = await psychClient.sendRequest('psychIde/resizeSpriteSheet', {
                    imagePath,
                    targetWidth: profile.width,
                    xmlPath,
                    jsonPaths: jsonCandidates,
                    outputImagePath,
                    outputXmlPath,
                    outputJsonPaths,
                    overwrite: false,
                }) as { ok?: boolean; error?: string; new_size?: number[] };

                if (!result.ok) {
                    results.push(`${path.basename(imagePath)} failed: ${result.error || 'unknown error'}`);
                } else {
                    results.push(`${path.basename(imagePath)} -> ${result.new_size ? result.new_size.join('x') : 'resized'}`);
                }
            }

            vscode.window.showInformationMessage(
                `${profile.label} batch export complete. ${results.length} processed. ${results.slice(0, 3).join(' | ')}`
            );
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.scanAssetHealth', async () => {
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }

            const folderUri = await vscode.window.showOpenDialog({
                canSelectFiles: false,
                canSelectFolders: true,
                canSelectMany: false,
                openLabel: 'Scan asset folder',
            });
            if (!folderUri || folderUri.length === 0) {
                return;
            }

            const profile = await pickExportProfile();
            if (!profile) {
                return;
            }

            const result = await psychClient.sendRequest('psychIde/scanAssetHealth', {
                folderPath: folderUri[0].fsPath,
                profile: profile.id,
            }) as {
                ok?: boolean;
                error?: string;
                totals?: { files?: number; bytes?: number; oversized?: number; missingMetadata?: number; invalidMetadata?: number };
                assets?: Array<{ path: string; issues: string[]; recommendations?: string[] }>;
            };

            if (!result.ok) {
                vscode.window.showErrorMessage(`Asset health scan failed: ${result.error || 'Unknown error'}`);
                return;
            }

            const totals = result.totals || {};
            output.appendLine(`Asset health scan: ${folderUri[0].fsPath}`);
            for (const asset of result.assets || []) {
                if (asset.issues.length > 0) {
                    output.appendLine(`${asset.path}: ${asset.issues.join(', ')}`);
                    for (const recommendation of asset.recommendations || []) {
                        output.appendLine(`  Recommendation: ${recommendation}`);
                    }
                }
            }
            output.show(true);

            vscode.window.showInformationMessage(
                `Asset scan complete: ${totals.files || 0} PNGs, ${totals.oversized || 0} oversized, ` +
                `${totals.missingMetadata || 0} missing metadata, ${totals.invalidMetadata || 0} invalid metadata.`
            );
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.validateWorkspace', async () => {
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }

            const result = await psychClient.sendRequest('psychIde/validateWorkspace', {}) as {
                ok?: boolean;
                totals?: { files?: number; errors?: number; warnings?: number };
                results?: Array<{ uri: string; errors: Array<{ message?: string }>; warnings: Array<{ message?: string }> }>;
            };
            if (!result.ok) {
                vscode.window.showErrorMessage('Workspace validation failed.');
                return;
            }

            output.appendLine('Workspace validation:');
            for (const file of result.results || []) {
                const label = vscode.Uri.parse(file.uri).fsPath;
                output.appendLine(`${label}: ${file.errors.length} errors, ${file.warnings.length} warnings`);
                for (const diagnostic of [...file.errors, ...file.warnings]) {
                    output.appendLine(`  ${diagnostic.message || 'Unknown diagnostic'}`);
                }
            }
            output.show(true);

            const totals = result.totals || {};
            vscode.window.showInformationMessage(
                `Workspace validation complete: ${totals.files || 0} files, ` +
                `${totals.errors || 0} errors, ${totals.warnings || 0} warnings.`
            );
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.previewSpriteSheet', async () => {
            const imageUri = await vscode.window.showOpenDialog({
                canSelectFiles: true,
                canSelectFolders: false,
                canSelectMany: false,
                filters: { 'Sprite sheets': ['png'] },
                openLabel: 'Preview sprite sheet',
            });
            if (!imageUri || imageUri.length === 0) {
                return;
            }
            await showSpritePreview(context, imageUri[0].fsPath);
        })
    );

    // Register validation command
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.validateLua', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {
                vscode.window.showErrorMessage('No file open');
                return;
            }
            if (!psychClient) {
                vscode.window.showErrorMessage('PsychIDE language server is not active.');
                return;
            }
            await psychClient.sendRequest('psychIde/validateDocument', {
                textDocument: {
                    uri: editor.document.uri.toString(),
                    text: editor.document.getText()
                }
            });
            vscode.window.showInformationMessage('Lua file validated by PsychIDE.');
        })
    );

    // Register JSON validation command
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.validateJson', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {
                vscode.window.showErrorMessage('No file open');
                return;
            }
            validateJsonFile(editor.document);
            vscode.window.showInformationMessage('✓ JSON file validated');
        })
    );

    // Register snippet generator
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.generateSnippet', async () => {
            const snippets = [
                'Shader Template',
                'Sprite + Tween',
                'Event Handler',
                'Character JSON'
            ];
            
            const choice = await vscode.window.showQuickPick(snippets);
            if (choice) {
                vscode.window.showInformationMessage(`Generated: ${choice}`);
            }
        })
    );

    // Register the AI Bug Fixer Command
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.askAiToFix', async () => {
            const activeEditor = vscode.window.activeTextEditor;
            if (!activeEditor) {
                vscode.window.showErrorMessage('Open a Lua file with an error to use this command.');
                return;
            }

            const documentUri = activeEditor.document.uri.toString();
            const currentLine = activeEditor.selection.active.line;

            vscode.window.withProgress({
                location: vscode.ProgressLocation.Notification,
                title: "🧠 PsychIDE AI is analyzing the bug...",
                cancellable: false
            }, async (progress) => {
                try {
                    if (!psychClient) {
                        throw new Error("Language client backend is not active.");
                    }

                    const storedKey = await context.secrets.get(aiKeySecretName);
                    if (!storedKey) {
                        const configured = await configureAiKey(context, true);
                        if (!configured) return;
                    }

                    const response = await psychClient.sendRequest('workspace/executeCommand', {
                        command: 'psychIde.askAiToFix',
                        arguments: [documentUri, currentLine]
                    }) as { fixed_code?: string; explanation?: string; error?: string };

                    if (response?.error) {
                        vscode.window.showErrorMessage(`AI Fix rejected: ${response.error}`);
                    } else if (response?.fixed_code) {
                        await activeEditor.edit(editBuilder => {
                            const lineRange = activeEditor.document.lineAt(currentLine).range;
                            editBuilder.replace(lineRange, response.fixed_code!);
                        });
                        vscode.window.showInformationMessage(response.explanation || 'AI fix applied and validated.');
                    } else {
                        vscode.window.showWarningMessage('AI returned an empty response or could not find a fix.');
                    }
                } catch (err: any) {
                    vscode.window.showErrorMessage(`AI Fix Error: ${err.message}`);
                }
            });
        })
    );

    // Watch Lua files for changes and validate on save
    context.subscriptions.push(
        vscode.workspace.onDidSaveTextDocument(document => {
            // The language server owns Lua diagnostics and receives didSave automatically.
        })
    );

    // Watch JSON files for changes
    context.subscriptions.push(
        vscode.workspace.onDidSaveTextDocument(document => {
            const fileName = path.basename(document.fileName);
            if (fileName === 'song.json' || fileName === 'character.json') {
                validateJsonFile(document);
            }
        })
    );

    // Provide hover hints for Psych functions
    context.subscriptions.push(
        vscode.languages.registerHoverProvider('lua', {
            provideHover(document, position, token) {
                const range = document.getWordRangeAtPosition(position);
                const word = document.getText(range);
                
                const psychFunctions: { [key: string]: string } = {
                    'initLuaShader': 'Initialize a Lua shader (e.g., `game.initLuaShader(\'heatwave\')`)',
                    'setSpriteShader': 'Apply shader to sprite/camera',
                    'setShaderFloat': 'Set float uniform (must be 0.0, not 0)',
                    'setShaderInt': 'Set integer uniform',
                    'setShaderVec2': 'Set vec2 uniform (2 float values)',
                    'setShaderVec3': 'Set vec3 uniform (3 float values)',
                    'makeLuaSprite': 'Create sprite instance',
                    'addLuaSprite': 'Add sprite to render queue',
                    'makeGraphic': 'Create graphic primitive',
                    'runHaxeCode': 'Execute Haxe code inline',
                    'debugPrint': 'Print debug message to console',
                    'getSongPosition': 'Get current song position in milliseconds',
                    'getVar': 'Get variable from game state',
                    'setVar': 'Set variable in game state',
                    'doTweenX': 'Animate X position',
                    'doTweenY': 'Animate Y position',
                };

                if (word in psychFunctions) {
                    return new vscode.Hover(new vscode.MarkdownString(`**${word}**\n\n${psychFunctions[word]}`));
                }
                return null;
            }
        })
    );

    console.log('Psych Engine IDE commands registered');
}

async function showSpritePreview(context: vscode.ExtensionContext, imagePath: string): Promise<void> {
    const imageData = fs.readFileSync(imagePath).toString('base64');
    const folder = path.dirname(imagePath);
    const baseName = path.basename(imagePath, path.extname(imagePath));
    const xmlPath = path.join(folder, `${baseName}.xml`);
    const frames = fs.existsSync(xmlPath) ? parseSpriteFrames(xmlPath) : [];
    const panel = vscode.window.createWebviewPanel(
        'psychideSpritePreview',
        `Sprite Preview: ${baseName}`,
        vscode.ViewColumn.Active,
        { enableScripts: true }
    );

    const nonce = `${Date.now()}${Math.random().toString(16).slice(2)}`;
    const frameJson = JSON.stringify(frames.length > 0 ? frames : [{ name: baseName, x: 0, y: 0, width: 0, height: 0 }])
        .replace(/</g, '\\u003c');
    panel.webview.html = `<!doctype html>
<html>
<head>
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src data:; style-src 'unsafe-inline'; script-src 'nonce-${nonce}';">
<style>
body { font-family: sans-serif; color: var(--vscode-foreground); background: var(--vscode-editor-background); padding: 16px; }
.toolbar { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
button, input { accent-color: var(--vscode-focusBorder); }
canvas { display: block; max-width: 100%; image-rendering: pixelated; margin-top: 16px; background: repeating-conic-gradient(#333 0 25%, #222 0 50%) 0 / 20px 20px; }
#status { opacity: .8; }
</style>
</head>
<body>
<div class="toolbar">
<button id="play">Play</button>
<label>Frame <input id="frame" type="range" min="0" max="${Math.max(frames.length - 1, 0)}" value="0"></label>
<label>FPS <input id="fps" type="number" min="1" max="60" value="12" size="3"></label>
<span id="status"></span>
</div>
<canvas id="preview"></canvas>
<script nonce="${nonce}">
const image = new Image();
const frames = ${frameJson};
const canvas = document.getElementById('preview');
const ctx = canvas.getContext('2d');
const frameInput = document.getElementById('frame');
const fpsInput = document.getElementById('fps');
const status = document.getElementById('status');
let timer = null;
function draw(index) {
  const frame = frames[index];
  const width = frame.width || image.naturalWidth;
  const height = frame.height || image.naturalHeight;
  canvas.width = width;
  canvas.height = height;
  ctx.clearRect(0, 0, width, height);
  ctx.drawImage(image, frame.x || 0, frame.y || 0, width, height, 0, 0, width, height);
  status.textContent = (frame.name || 'frame') + ' ' + (index + 1) + '/' + frames.length + ' (' + width + 'x' + height + ')';
}
function stop() { if (timer) { clearInterval(timer); timer = null; } document.getElementById('play').textContent = 'Play'; }
document.getElementById('play').addEventListener('click', () => {
  if (timer) { stop(); return; }
  document.getElementById('play').textContent = 'Pause';
  timer = setInterval(() => { frameInput.value = String((Number(frameInput.value) + 1) % frames.length); draw(Number(frameInput.value)); }, 1000 / Number(fpsInput.value || 12));
});
frameInput.addEventListener('input', () => { stop(); draw(Number(frameInput.value)); });
fpsInput.addEventListener('change', () => { if (timer) { stop(); document.getElementById('play').click(); } });
image.onload = () => draw(0);
image.src = 'data:image/png;base64,${imageData}';
</script>
</body>
</html>`;
}

function parseSpriteFrames(xmlPath: string): Array<{ name: string; x: number; y: number; width: number; height: number }> {
    const xml = fs.readFileSync(xmlPath, 'utf8');
    const frames: Array<{ name: string; x: number; y: number; width: number; height: number }> = [];
    for (const match of xml.matchAll(/<SubTexture\b([^>]*)\/?>(?:<\/SubTexture>)?/g)) {
        const attributes = match[1];
        const read = (name: string, fallback: string) => {
            const value = attributes.match(new RegExp(`${name}=["']([^"']+)["']`));
            return value ? value[1] : fallback;
        };
        frames.push({
            name: read('name', `frame-${frames.length}`),
            x: Number(read('x', '0')) || 0,
            y: Number(read('y', '0')) || 0,
            width: Number(read('width', '0')) || 0,
            height: Number(read('height', '0')) || 0,
        });
    }
    return frames;
}

function validateJsonFile(document: vscode.TextDocument) {
    const diagnostics: vscode.Diagnostic[] = [];
    try {
        JSON.parse(document.getText());
    } catch (error: any) {
        const match = error.message.match(/position (\d+)/);
        if (match) {
            const pos = parseInt(match[1]);
            let lineNum = 0;
            let col = pos;
            const lines = document.getText().split('\n');
            for (let i = 0; i < lines.length; i++) {
                if (col <= lines[i].length) {
                    lineNum = i;
                    break;
                }
                col -= lines[i].length + 1;
            }
            diagnostics.push(new vscode.Diagnostic(
                new vscode.Range(lineNum, col, lineNum, col + 1),
                `JSON Error: ${error.message}`,
                vscode.DiagnosticSeverity.Error
            ));
        }
    }

    diagnosticCollection.set(document.uri, diagnostics);
}

type ExportProfile = {
    id: string;
    label: string;
    width: number;
};

async function pickExportProfile(): Promise<ExportProfile | undefined> {
    const presetItems = [
        { id: 'low-end', label: 'Low-end export (1024)', width: 1024 },
        { id: 'balanced', label: 'Balanced export (1536)', width: 1536 },
        { id: 'standard', label: 'Standard export (2048)', width: 2048 },
        { id: 'high-end', label: 'High-end export (4096)', width: 4096 },
        { id: 'custom', label: 'Custom export width…', width: -1 },
    ];

    const preset = await vscode.window.showQuickPick(
        presetItems.map(item => ({ label: item.label, description: `${item.width}px`, item })),
        { placeHolder: 'Choose target resolution for the sprite sheet' }
    );

    if (!preset) {
        return undefined;
    }

    let targetWidth = preset.item.width;
    if (targetWidth === -1) {
        const customValue = await vscode.window.showInputBox({
            prompt: 'Enter a target width in pixels',
            placeHolder: '2048',
            validateInput: value => {
                const width = Number(value);
                if (!Number.isFinite(width) || width <= 0) {
                    return 'Enter a positive number.';
                }
                return undefined;
            },
        });
        if (!customValue) {
            return undefined;
        }
        targetWidth = Number(customValue);
    }

    return {
        id: preset.item.id === 'custom' ? `custom-${targetWidth}` : preset.item.id,
        label: preset.item.id === 'custom' ? `Custom export (${targetWidth}px)` : preset.item.label,
        width: targetWidth,
    };
}

function findImageFiles(root: string, excludedRoot: string): string[] {
    const images: string[] = [];
    const visit = (directory: string): void => {
        if (directory === excludedRoot || directory.startsWith(`${excludedRoot}${path.sep}`)) {
            return;
        }

        for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
            const entryPath = path.join(directory, entry.name);
            if (entry.isDirectory()) {
                visit(entryPath);
                continue;
            }
            if (path.extname(entry.name).toLowerCase() === '.png') {
                images.push(entryPath);
            }
        }
    };

    visit(root);
    return images;
}

export function deactivate() {}

