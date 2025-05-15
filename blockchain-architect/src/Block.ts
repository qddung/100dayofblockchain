import crypto from 'crypto-js';
import { Transaction, BlockData } from './types';

export class Block {
    public hash: string;

    constructor(
        public readonly index: number,
        public readonly transactions: Transaction[],
        public readonly timestamp: number,
        public readonly previousHash: string,
        public nonce: number = 0
    ) {
        this.hash = this.calculateHash();
    }

    public calculateHash(): string {
        const blockString = JSON.stringify({
            index: this.index,
            transactions: this.transactions,
            timestamp: this.timestamp,
            previousHash: this.previousHash,
            nonce: this.nonce
        });
        return crypto.SHA256(blockString).toString();
    }

    public mineBlock(difficulty: number): void {
        const target = Array(difficulty + 1).join("0");
        while (this.hash.substring(0, difficulty) !== target) {
            this.nonce++;
            this.hash = this.calculateHash();
        }
    }

    public toJSON(): BlockData {
        return {
            index: this.index,
            transactions: this.transactions,
            timestamp: this.timestamp,
            previousHash: this.previousHash,
            nonce: this.nonce,
            hash: this.hash
        };
    }

    public static fromJSON(data: BlockData): Block {
        const block = new Block(
            data.index,
            data.transactions,
            data.timestamp,
            data.previousHash,
            data.nonce
        );
        block.hash = data.hash;
        return block;
    }
} 