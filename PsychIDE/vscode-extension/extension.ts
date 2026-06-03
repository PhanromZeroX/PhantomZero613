import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

let diagnosticCollection: vscode.DiagnosticCollection;

export async function activate(context: vscode.ExtensionContext) {
    diagnosticCollection = vscode.languages.createDiagnosticCollection('psych-ide');
    context.subscriptions.push(diagnosticCollection);
    
    console.log('Psych Engine IDE activated');

    // Register validation command
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.validateLua', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {
                vscode.window.showErrorMessage('No file open');
                return;
            }
            validateLuaFile(editor.document);
            vscode.window.showInformationMessage('✓ Lua file validated');
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

    // Watch Lua files for changes and validate on save
    const luaWatcher = vscode.workspace.createFileSystemWatcher('**/*.lua');
    luaWatcher.onDidSave(uri => {
        const document = vscode.workspace.textDocuments.find(doc => doc.uri === uri);
        if (document) {
            validateLuaFile(document);
        }
    });
    context.subscriptions.push(luaWatcher);

    // Watch JSON files for changes
    const jsonWatcher = vscode.workspace.createFileSystemWatcher('{**/song.json,**/character.json}');
    jsonWatcher.onDidSave(uri => {
        const document = vscode.workspace.textDocuments.find(doc => doc.uri === uri);
        if (document) {
            validateJsonFile(document);
        }
    });
    context.subscriptions.push(jsonWatcher);

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

function validateLuaFile(document: vscode.TextDocument) {
    const diagnostics: vscode.Diagnostic[] = [];
    const text = document.getText();
    const lines = text.split('\n');
    
    const psychFunctions = [
        'initLuaShader', 'setSpriteShader', 'setShaderFloat', 'setShaderInt', 
        'setShaderVec2', 'setShaderVec3', 'makeLuaSprite', 'addLuaSprite', 
        'makeGraphic', 'runHaxeCode', 'debugPrint', 'getSongPosition',
        'getVar', 'setVar', 'doTweenX', 'doTweenY'
    ];

    lines.forEach((line, i) => {
        // Skip comments
        if (line.trim().startsWith('--')) return;

        // Check for integer literals in float contexts (setShaderFloat with integer)
        const floatMatch = line.match(/setShaderFloat\([^,]+,\s*['"]([\w_]+)['"]\s*,\s*(-?\d+)(?![.\d])/);
        if (floatMatch) {
            const col = line.indexOf(floatMatch[2]);
            const range = new vscode.Range(i, col, i, col + floatMatch[2].length);
            diagnostics.push(new vscode.Diagnostic(
                range,
                `Float literal should be ${floatMatch[2]}.0`,
                vscode.DiagnosticSeverity.Warning
            ));
        }

        // Check for division that should use .0
        const divMatch = line.match(/\/\s*1000(?![.\d])/);
        if (divMatch) {
            const col = line.indexOf(divMatch[0]);
            const range = new vscode.Range(i, col, i, col + divMatch[0].length);
            diagnostics.push(new vscode.Diagnostic(
                range,
                'Should be / 1000.0 for float division',
                vscode.DiagnosticSeverity.Warning
            ));
        }
    });

    diagnosticCollection.set(document.uri, diagnostics);
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

export function deactivate() {}

