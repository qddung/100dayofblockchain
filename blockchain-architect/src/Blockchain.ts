import { Block } from './Block';
import { Transaction } from './types';

export class Blockchain {
    private chain: Block[];
    private pendingTransactions: Transaction[];
    private readonly miningReward: number;

    private readonly difficulty: number;

    constructor(difficulty: number = 4) {
        this.chain = [];
        this.pendingTransactions = [];
        this.miningReward = 10;
        this.difficulty = difficulty;
        this.createGenesisBlock();
    }

    private createGenesisBlock(): void {
        const genesisBlock = new Block(0, [], Date.now(), "0");
        genesisBlock.mineBlock(this.difficulty);
        this.chain.push(genesisBlock);
    }

    public getLatestBlock(): Block {
        return this.chain[this.chain.length - 1];
    }

    public addTransaction(
        sender: string,
        recipient: string,
        amount: number,
        signature?: string
    ): boolean {
        if (sender === "network") {
            this.pendingTransactions.push({
                sender,
                recipient,
                amount,
                timestamp: Date.now()
            });
            return true;
        }

        if (!signature) {
            return false;
        }

        const transaction: Transaction = {
            sender,
            recipient,
            amount,
            timestamp: Date.now(),
            signature
        };

        // In a real implementation, verify the signature here
        this.pendingTransactions.push(transaction);
        return true;
    }

    public minePendingTransactions(minerAddress: string): Block {
        // Create mining reward transaction
        this.addTransaction("network", minerAddress, this.miningReward);

        // Create new block
        const block = new Block(
            this.chain.length,
            this.pendingTransactions,
            Date.now(),
            this.getLatestBlock().hash
        );

        // Mine the block
        block.mineBlock(this.difficulty);

        // Add block to chain
        this.chain.push(block);

        // Clear pending transactions
        this.pendingTransactions = [];

        return block;
    }

    public isChainValid(): boolean {
        for (let i = 1; i < this.chain.length; i++) {
            const currentBlock = this.chain[i];
            const previousBlock = this.chain[i - 1];

            // Verify current block's hash
            if (currentBlock.hash !== currentBlock.calculateHash()) {
                return false;
            }

            // Verify chain link
            if (currentBlock.previousHash !== previousBlock.hash) {
                return false;
            }

            // Verify proof of work
            if (currentBlock.hash.substring(0, this.difficulty) !== Array(this.difficulty + 1).join("0")) {
                return false;
            }
        }

        return true;
    }

    public getBalance(address: string): number {
        let balance = 0;

        for (const block of this.chain) {
            for (const transaction of block.transactions) {
                if (transaction.sender === address) {
                    balance -= transaction.amount;
                }
                if (transaction.recipient === address) {
                    balance += transaction.amount;
                }
            }
        }

        return balance;
    }

    public toJSON() {
        return {
            chain: this.chain.map(block => block.toJSON()),
            difficulty: this.difficulty,
            pendingTransactions: this.pendingTransactions,
            miningReward: this.miningReward
        };
    }

    public static fromJSON(data: any): Blockchain {
        const blockchain = new Blockchain(data.difficulty);
        blockchain.chain = data.chain.map(Block.fromJSON);
        blockchain.pendingTransactions = data.pendingTransactions;
        return blockchain;
    }
} 