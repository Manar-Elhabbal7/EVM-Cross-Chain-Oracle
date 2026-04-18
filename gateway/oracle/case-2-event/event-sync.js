const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const RPC_A = process.env.RPC_A || "http://127.0.0.1:8545";
    const RPC_B = process.env.RPC_B || "http://127.0.0.1:8546";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const ADDRESS_A = process.env.ADDRESS_A;
    const ADDRESS_B = process.env.ADDRESS_B;

    const providerA = new ethers.JsonRpcProvider(RPC_A);
    const providerB = new ethers.JsonRpcProvider(RPC_B);
    const walletB = new ethers.Wallet(PRIVATE_KEY, providerB);

    const abi = [
        "event ValueChanged(uint oldValue, uint newValue)",
        "function setValue(uint _value)"
    ];

    const contractA = new ethers.Contract(ADDRESS_A, abi, providerA);
    const contractB = new ethers.Contract(ADDRESS_B, abi, walletB);

    console.log(`[Event-Driven Oracle] Listening on Chain A: ${ADDRESS_A}...`);

    contractA.on("ValueChanged", async (oldValue, newValue, event) => {
        console.log(`\n🔔 Event detected on Chain A: ${oldValue} -> ${newValue}`);
        try {
            console.log(`Propagating to Chain B...`);
            const tx = await contractB.setValue(newValue);
            await tx.wait();
            console.log(`✅ Successfully synced to Chain B: ${tx.hash}`);
        } catch (err) {
            console.error(`❌ Sync failed:`, err.message);
        }
    });

    process.on("SIGINT", () => {
        console.log("\nOracle shutting down...");
        process.exit();
    });
}

main().catch(console.error);
