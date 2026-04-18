const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const RPC_A = process.env.RPC_A || "http://127.0.0.1:8545";
    const RPC_B = process.env.RPC_B || "http://127.0.0.1:8546";
    const RPC_C = process.env.RPC_C || "http://127.0.0.1:8547";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const ADDRESS_A = process.env.ADDRESS_A;
    const ADDRESS_B = process.env.ADDRESS_B;
    const ADDRESS_C = process.env.ADDRESS_C;

    const providerA = new ethers.JsonRpcProvider(RPC_A);
    const providerB = new ethers.JsonRpcProvider(RPC_B);
    const providerC = new ethers.JsonRpcProvider(RPC_C);
    
    const walletB = new ethers.Wallet(PRIVATE_KEY, providerB);
    const walletC = new ethers.Wallet(PRIVATE_KEY, providerC);

    const abi = [
        "event ValueChanged(uint oldValue, uint newValue)",
        "function setValue(uint _value)"
    ];

    const contractA = new ethers.Contract(ADDRESS_A, abi, providerA);
    const contractB = new ethers.Contract(ADDRESS_B, abi, walletB);
    const contractC = new ethers.Contract(ADDRESS_C, abi, walletC);

    console.log(`[Multi-Sync Oracle] Listening on Chain A: ${ADDRESS_A}...`);
    console.log(`[Multi-Sync Oracle] Propagating to Chain B: ${ADDRESS_B}`);
    console.log(`[Multi-Sync Oracle] Propagating to Chain C: ${ADDRESS_C}`);

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
                console.log(`\n🌐 Multi-sync trigger: ${oldValue} -> ${newValue}`);

                try {
                    console.log(`Propagating to Chain B...`);
                    const tx1 = await contractB.setValue(newValue);
                    await tx1.wait();
                    console.log(`✅ Synced to Chain B: ${tx1.hash}`);

                    console.log(`Propagating to Chain C...`);
                    const tx2 = await contractC.setValue(newValue);
                    await tx2.wait();
                    console.log(`✅ Synced to Chain C: ${tx2.hash}`);
                } catch (err) {
                    console.error(`❌ Multi-sync failed:`, err.message);
                }
            }
            lastBlock = currentBlock;
        } catch (err) {
            console.error("Polling error:", err.message);
        }
    }, 1000); // Poll every 1 second

    process.on("SIGINT", () => {
        console.log("\nOracle shutting down...");
        process.exit();
    });
}

main().catch(console.error);
