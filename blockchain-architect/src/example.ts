import { Blockchain } from './Blockchain';
import { Wallet } from './Wallet';
import { TokenContract, CrowdfundingContract } from './SmartContract';
import { Node } from './Network';

async function main() {
    // Create blockchain
    const blockchain = new Blockchain(4); // difficulty of 4

    // Create wallets
    const alice = new Wallet();
    const bob = new Wallet();

    // Create and deploy a token contract
    const tokenContract = new TokenContract(alice.address, 1000);
    console.log('Token contract deployed at:', tokenContract.contractAddress);

    // Transfer tokens
    const transferAmount = 100;
    const transferParams = { to: bob.address, amount: transferAmount };
    const success = tokenContract.execute('transfer', transferParams, alice.address);
    console.log('Transfer success:', success);

    // Check balances
    const aliceBalance = tokenContract.execute('balanceOf', { address: alice.address }, alice.address);
    const bobBalance = tokenContract.execute('balanceOf', { address: bob.address }, bob.address);
    console.log('Alice balance:', aliceBalance);
    console.log('Bob balance:', bobBalance);

    // Create and deploy a crowdfunding contract
    const deadline = Date.now() + 24 * 60 * 60 * 1000; // 24 hours from now
    const crowdfunding = new CrowdfundingContract(alice.address, 1000, deadline);
    console.log('Crowdfunding contract deployed at:', crowdfunding.contractAddress);

    // Bob contributes to the crowdfunding
    const contribution = 500;
    const contributionSuccess = crowdfunding.execute('contribute', { amount: contribution }, bob.address);
    console.log('Contribution success:', contributionSuccess);

    // Check contribution
    const bobContribution = crowdfunding.execute('getContribution', { address: bob.address }, bob.address);
    console.log('Bob contribution:', bobContribution);

    // Start a node
    const node = new Node('localhost', 3000);
    await node.start();
    console.log('Node started');

    // Connect to another node (if it exists)
    try {
        await node.connectToPeer('ws://localhost:3001');
        console.log('Connected to peer');
    } catch (error) {
        console.error('Failed to connect to peer:', error);
    }

    // Create and mine a block with a transaction
    const transaction = {
        sender: alice.address,
        recipient: bob.address,
        amount: 50,
        timestamp: Date.now()
    };

    // Sign the transaction
    const signature = alice.signTransaction(transaction);
    
    // Add transaction to blockchain
    blockchain.addTransaction(
        transaction.sender,
        transaction.recipient,
        transaction.amount,
        signature
    );

    // Mine the block
    const newBlock = blockchain.minePendingTransactions(alice.address);
    console.log('New block mined:', newBlock.hash);

    // Verify the blockchain
    console.log('Blockchain valid:', blockchain.isChainValid());

    // Clean up
    node.stop();
}

main().catch(console.error); 