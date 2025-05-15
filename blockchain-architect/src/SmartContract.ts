import { SmartContractState, TokenState, CrowdfundingState } from './types';

export abstract class SmartContract {
    protected state: SmartContractState = {};
    public readonly contractAddress: string;
    private readonly createdAt: number;

    constructor(
        public readonly creatorAddress: string,
        public readonly contractCode: string
    ) {
        this.createdAt = Date.now();
        this.contractAddress = this.generateContractAddress();
    }

    private generateContractAddress(): string {
        return `contract_${this.creatorAddress}_${this.createdAt}`;
    }

    public abstract execute(method: string, params: Record<string, any>, sender: string): any;
}

export class TokenContract extends SmartContract {
    protected state: TokenState;

    constructor(creatorAddress: string, initialSupply: number) {
        super(creatorAddress, "token_contract");
        this.state = {
            balances: { [creatorAddress]: initialSupply },
            totalSupply: initialSupply,
            name: "SimpleToken",
            symbol: "STK"
        };
    }

    public execute(method: string, params: Record<string, any>, sender: string): any {
        switch (method) {
            case 'transfer':
                return this.transfer({
                    to: params.to as string,
                    amount: params.amount as number
                }, sender);
            case 'balanceOf':
                return this.balanceOf({
                    address: params.address as string | undefined
                }, sender);
            default:
                throw new Error(`Method ${method} not found`);
        }
    }

    private transfer(params: { to: string; amount: number }, sender: string): boolean {
        const { to, amount } = params;

        if (!to || typeof amount !== 'number' || amount <= 0) {
            return false;
        }

        const senderBalance = this.state.balances[sender] || 0;
        if (senderBalance < amount) {
            return false;
        }

        this.state.balances[sender] = senderBalance - amount;
        this.state.balances[to] = (this.state.balances[to] || 0) + amount;

        return true;
    }

    private balanceOf(params: { address?: string }, sender: string): number {
        const address = params.address || sender;
        return this.state.balances[address] || 0;
    }
}

export class CrowdfundingContract extends SmartContract {
    protected state: CrowdfundingState;

    constructor(creatorAddress: string, goal: number, deadline: number) {
        super(creatorAddress, "crowdfunding_contract");
        this.state = {
            goal,
            deadline,
            contributions: {},
            totalRaised: 0,
            completed: false
        };
    }

    public execute(method: string, params: Record<string, any>, sender: string): any {
        switch (method) {
            case 'contribute':
                return this.contribute({
                    amount: params.amount as number
                }, sender);
            case 'checkGoalReached':
                return this.checkGoalReached(params, sender);
            case 'getContribution':
                return this.getContribution({
                    address: params.address as string | undefined
                }, sender);
            default:
                throw new Error(`Method ${method} not found`);
        }
    }

    private contribute(params: { amount: number }, sender: string): boolean {
        const { amount } = params;

        if (typeof amount !== 'number' || amount <= 0) {
            return false;
        }

        if (Date.now() > this.state.deadline) {
            return false;
        }

        this.state.contributions[sender] = (this.state.contributions[sender] || 0) + amount;
        this.state.totalRaised += amount;

        return true;
    }

    private checkGoalReached(_params: Record<string, any>, _sender: string): boolean {
        if (Date.now() <= this.state.deadline) {
            return false;
        }

        return this.state.totalRaised >= this.state.goal;
    }

    private getContribution(params: { address?: string }, sender: string): number {
        const address = params.address || sender;
        return this.state.contributions[address] || 0;
    }
} 