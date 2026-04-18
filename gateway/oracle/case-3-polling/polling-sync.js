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

    const abi = ["function getValue() view returns (uint)", "function setValue(uint _value)"];
    const contractA = new ethers.Contract(ADDRESS_A, abi, providerA);
    const contractB = new ethers.Contract(ADDRESS_B, abi, walletB);

    let lastValue = await contractA.getValue();
    console.log(`[Polling Oracle] Initial value on Chain A: ${lastValue}. Polling every 3s...`);

    setInterval(async () => {
        try {
            const currentValue = await contractA.getValue();
            if (currentValue !== lastValue) {
                console.log(`\n🔍 Change detected by polling: ${lastValue} -> ${currentValue}`);
                console.log(`Propagating to Chain B...`);
                const tx = await contractB.setValue(currentValue);
                await tx.wait();
                console.log(`✅ Successfully synced: ${tx.hash}`);
                lastValue = currentValue;
            }
        } catch (err) {
            console.error("Polling error:", err.message);
        }
    }, 3000);

    process.on("SIGINT", () => {
        console.log("\nOracle shutting down...");
        process.exit();
    });
}

main().catch(console.error);
