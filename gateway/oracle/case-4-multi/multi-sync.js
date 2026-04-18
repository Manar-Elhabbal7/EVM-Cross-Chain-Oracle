const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const RPC_A = process.env.RPC_A || "http://127.0.0.1:8545";
    const RPC_B = process.env.RPC_B || "http://127.0.0.1:8546";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const ADDRESS_A = process.env.ADDRESS_A;
    const ADDRESS_B1 = process.env.ADDRESS_B1;
    const ADDRESS_B2 = process.env.ADDRESS_B2;

    const providerA = new ethers.JsonRpcProvider(RPC_A);
    const providerB = new ethers.JsonRpcProvider(RPC_B);
    const walletB = new ethers.Wallet(PRIVATE_KEY, providerB);

    const abi = [
        "event ValueChanged(uint oldValue, uint newValue)",
        "function setValue(uint _value)"
    ];

    const contractA = new ethers.Contract(ADDRESS_A, abi, providerA);
    const contractB1 = new ethers.Contract(ADDRESS_B1, abi, walletB);
    const contractB2 = new ethers.Contract(ADDRESS_B2, abi, walletB);

    console.log(`[Multi-Sync Oracle] Listening on Chain A: ${ADDRESS_A}...`);
    console.log(`[Multi-Sync Oracle] Propagating to Destination 1: ${ADDRESS_B1}`);
    console.log(`[Multi-Sync Oracle] Propagating to Destination 2: ${ADDRESS_B2}`);

    contractA.on("ValueChanged", async (oldValue, newValue) => {
        console.log(`\n🌐 Multi-sync trigger: ${oldValue} -> ${newValue}`);
        
        try {
            console.log(`Propagating to Destination 1...`);
            const tx1 = await contractB1.setValue(newValue);
            await tx1.wait();
            console.log(`✅ Synced to Destination 1: ${tx1.hash}`);

            console.log(`Propagating to Destination 2...`);
            const tx2 = await contractB2.setValue(newValue);
            await tx2.wait();
            console.log(`✅ Synced to Destination 2: ${tx2.hash}`);
        } catch (err) {
            console.error(`❌ Multi-sync failed:`, err.message);
        }
    });

    process.on("SIGINT", () => {
        console.log("\nOracle shutting down...");
        process.exit();
    });
}

main().catch(console.error);
