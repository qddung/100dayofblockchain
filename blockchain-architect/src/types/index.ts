export interface Transaction {
    sender: string;
    recipient: string;
    amount: number;
    timestamp: number;
    signature?: string;
}

export interface BlockData {
    index: number;
    transactions: Transaction[];
    timestamp: number;
    previousHash: string;
    nonce: number;
    hash: string;
}

export interface SmartContractState {
    [key: string]: any;
}

export interface TokenState extends SmartContractState {
    balances: { [address: string]: number };
    totalSupply: number;
    name: string;
    symbol: string;
}

export interface CrowdfundingState extends SmartContractState {
    goal: number;
    deadline: number;
    contributions: { [address: string]: number };
    totalRaised: number;
    completed: boolean;
}

export interface NetworkMessage {
    type: 'chain' | 'transaction' | 'block';
    data: any;
} 