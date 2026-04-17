const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    // Configuration from environment variables
    const RPC_A = process.env.RPC_A || "http://127.0.0.1:8545";
    const RPC_B = process.env.RPC_B || "http://127.0.0.1:8546";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const ADDRESS_A = process.env.ADDRESS_A;
    const ADDRESS_B = process.env.ADDRESS_B;

    if (!PRIVATE_KEY || !ADDRESS_A || !ADDRESS_B) {
        console.error("Missing required environment variables (PRIVATE_KEY, ADDRESS_A, ADDRESS_B)");
        process.exit(1);
    }

    // Providers
    const providerA = new ethers.JsonRpcProvider(RPC_A);
    const providerB = new ethers.JsonRpcProvider(RPC_B);
    
    // Signer for Chain B
    const walletB = new ethers.Wallet(PRIVATE_KEY, providerB);

    // ABI
    const abi = [
        "event ValueChanged(uint oldValue, uint newValue)",
        "function setValue(uint _value)",
        "function getValue() view returns (uint)"
    ];

    // Contracts
    const contractA = new ethers.Contract(ADDRESS_A, abi, providerA);
    const contractB = new ethers.Contract(ADDRESS_B, abi, walletB);

    console.log(`Oracle started...`);
    console.log(`Listening on Chain A: ${ADDRESS_A}`);
    console.log(`Syncing to Chain B: ${ADDRESS_B}`);

    let lastBlock = await providerA.getBlockNumber();
    console.log(`Starting sync from block: ${lastBlock}`);

    // Polling loop for stability
    setInterval(async () => {
        try {
            const currentBlock = await providerA.getBlockNumber();
            if (currentBlock <= lastBlock) return;

            const events = await contractA.queryFilter("ValueChanged", lastBlock + 1, currentBlock);
            
            for (const event of events) {
                const { oldValue, newValue } = event.args;
                console.log(`\n[Event Detected on Chain A]`);
                console.log(`Old Value: ${oldValue}`);
                console.log(`New Value: ${newValue}`);
                console.log(`Transaction Hash: ${event.transactionHash}`);

                try {
                    console.log(`Propagating change to Chain B...`);
                    const tx = await contractB.setValue(newValue);
                    console.log(`Transaction sent: ${tx.hash}`);
                    
                    const receipt = await tx.wait();
                    console.log(`Successfully synced to Chain B in block ${receipt.blockNumber}`);
                } catch (err) {
                    console.error(`Failed to sync to Chain B:`, err.message);
                }
            }
            lastBlock = currentBlock;
        } catch (err) {
            console.error("Polling error:", err.message);
        }
    }, 2000); // Poll every 2 seconds

    // Keep the process alive
    process.on("SIGINT", () => {
        console.log("\nOracle shutting down...");
        process.exit();
    });
}

main().catch(console.error);
