const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const RPC_A = process.env.RPC_A || "http://127.0.0.1:8545";
    const RPC_B = process.env.RPC_B || "http://127.0.0.1:8546";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const ADDRESS_A = process.env.ADDRESS_A;
    const ADDRESS_B = process.env.ADDRESS_B;

    if (!PRIVATE_KEY || !ADDRESS_A || !ADDRESS_B) {
        console.error("Missing environment variables (PRIVATE_KEY, ADDRESS_A, ADDRESS_B)");
        process.exit(1);
    }

    const providerA = new ethers.JsonRpcProvider(RPC_A);
    const providerB = new ethers.JsonRpcProvider(RPC_B);
    const walletB = new ethers.Wallet(PRIVATE_KEY, providerB);

    const abi = ["function getValue() view returns (uint)", "function setValue(uint _value)"];
    const contractA = new ethers.Contract(ADDRESS_A, abi, providerA);
    const contractB = new ethers.Contract(ADDRESS_B, abi, walletB);

    console.log("Reading value from Chain A...");
    const valueA = await contractA.getValue();
    console.log(`Current value on Chain A: ${valueA}`);

    console.log(`Propagating value to Chain B (${ADDRESS_B})...`);
    const tx = await contractB.setValue(valueA);
    await tx.wait();
    console.log("✅ Sync completed successfully!");
}

main().catch(console.error);
