import WebSocket from 'ws';
import { Blockchain } from './Blockchain';
import { NetworkMessage } from './types';

export class Node {
    private peers: Set<string>;
    private blockchain: Blockchain;
    private server: WebSocket.Server | null;

    constructor(
        private readonly host: string,
        private readonly port: number
    ) {
        this.peers = new Set();
        this.blockchain = new Blockchain();
        this.server = null;
    }

    public async start(): Promise<void> {
        this.server = new WebSocket.Server({ host: this.host, port: this.port });

        this.server.on('connection', (socket: WebSocket) => {
            this.handleConnection(socket);
        });

        console.log(`Node started on ws://${this.host}:${this.port}`);
    }

    public async connectToPeer(peerAddress: string): Promise<void> {
        try {
            const socket = new WebSocket(peerAddress);
            
            socket.on('open', () => {
                this.peers.add(peerAddress);
                this.sendChain(socket);
            });

            socket.on('close', () => {
                this.peers.delete(peerAddress);
            });

            socket.on('message', (data: WebSocket.Data) => {
                this.handleMessage(socket, data.toString());
            });
        } catch (error) {
            console.error(`Failed to connect to peer ${peerAddress}:`, error);
            this.peers.delete(peerAddress);
        }
    }

    private async broadcast(message: NetworkMessage): Promise<void> {
        const messageStr = JSON.stringify(message);
        const promises = Array.from(this.peers).map(peer => 
            this.sendToPeer(peer, messageStr)
        );
        await Promise.all(promises);
    }

    private async sendToPeer(peer: string, message: string): Promise<void> {
        try {
            const socket = new WebSocket(peer);
            socket.on('open', () => {
                socket.send(message);
                socket.close();
            });
        } catch (error) {
            console.error(`Failed to send message to peer ${peer}:`, error);
            this.peers.delete(peer);
        }
    }

    private handleConnection(socket: WebSocket): void {
        const peerAddress = this.getPeerAddress(socket);
        this.peers.add(peerAddress);

        socket.on('message', (data: WebSocket.Data) => {
            this.handleMessage(socket, data.toString());
        });

        socket.on('close', () => {
            this.peers.delete(peerAddress);
        });

        socket.on('error', (error: Error) => {
            console.error('WebSocket error:', error);
            this.peers.delete(peerAddress);
        });
    }

    private async handleMessage(socket: WebSocket, message: string): Promise<void> {
        try {
            const data = JSON.parse(message) as NetworkMessage;

            switch (data.type) {
                case 'chain':
                    const receivedChain = Blockchain.fromJSON(data.data);
                    if (receivedChain.isChainValid() && 
                        receivedChain.toJSON().chain.length > this.blockchain.toJSON().chain.length) {
                        this.blockchain = receivedChain;
                        await this.broadcast({ type: 'chain', data: this.blockchain.toJSON() });
                    }
                    break;

                case 'transaction':
                    const transaction = data.data;
                    if (this.blockchain.addTransaction(
                        transaction.sender,
                        transaction.recipient,
                        transaction.amount,
                        transaction.signature
                    )) {
                        await this.broadcast(data);
                    }
                    break;

                case 'block':
                    // Handle new block
                    break;
            }
        } catch (error) {
            console.error('Error handling message:', error);
        }
    }

    private async sendChain(socket: WebSocket): Promise<void> {
        const message: NetworkMessage = {
            type: 'chain',
            data: this.blockchain.toJSON()
        };
        socket.send(JSON.stringify(message));
    }

    private getPeerAddress(socket: WebSocket): string {
        const addr = (socket as any)._socket.remoteAddress;
        const port = (socket as any)._socket.remotePort;
        return `ws://${addr}:${port}`;
    }

    public stop(): void {
        if (this.server) {
            this.server.close();
            this.peers.clear();
        }
    }
} 