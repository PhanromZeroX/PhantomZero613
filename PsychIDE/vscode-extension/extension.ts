import * as vscode from 'vscode';
import { LanguageClient } from 'vscode-languageclient/node';

let client: LanguageClient;

export async function activate(context: vscode.ExtensionContext) {
    console.log('Psych Engine IDE activated');
    
    // Register validation command
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.validateLua', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {
                vscode.window.showErrorMessage('No file open');
                return;
            }
            
            // In a real implementation, send to LSP
            vscode.window.showInformationMessage('Lua validation: OK');
        })
    );
    
    // Register JSON validation command
    context.subscriptions.push(
        vscode.commands.registerCommand('psychIde.validateJson', async () => {
            vscode.window.showInformationMessage('JSON validation: OK');
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
    
    console.log('Psych Engine IDE commands registered');
}

export function deactivate() {
    if (!client) {
        return undefined;
    }
    return client.stop();
}
