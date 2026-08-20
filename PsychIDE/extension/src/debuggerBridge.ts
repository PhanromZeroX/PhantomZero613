import * as net from 'net';

/**
 * Sends a command string directly to the Psych Engine debug port.
 * @param command - The string command to send (e.g., 'reload_script').
 */
export function sendCommandToGame(command: string, host = '127.0.0.1', port = 8000): Promise<void> {
    const client = new net.Socket();

    return new Promise((resolve, reject) => {
        client.setTimeout(1500);
        client.connect(port, host, () => {
            client.end(`${command}\n`, () => resolve());
        });
        client.on('timeout', () => {
            client.destroy();
            reject(new Error(`Timed out connecting to ${host}:${port}.`));
        });
        client.on('error', (error) => {
            reject(new Error(`Game debug server unavailable at ${host}:${port}: ${error.message}`));
        });
    });
}

export function checkGameConnection(host = '127.0.0.1', port = 8000): Promise<void> {
    const client = new net.Socket();

    return new Promise((resolve, reject) => {
        client.setTimeout(1500);
        client.connect(port, host, () => {
            client.destroy();
            resolve();
        });
        client.on('timeout', () => {
            client.destroy();
            reject(new Error(`Timed out connecting to ${host}:${port}.`));
        });
        client.on('error', (error) => {
            reject(new Error(`Game debug server unavailable at ${host}:${port}: ${error.message}`));
        });
    });
}