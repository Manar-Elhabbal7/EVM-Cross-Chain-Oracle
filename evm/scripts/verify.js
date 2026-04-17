import hre from "hardhat";

async function main() {
  const contractAddress = process.env.ADDRESS_B || "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const Storage = await hre.ethers.getContractFactory("Storage");
  const storage = Storage.attach(contractAddress);
  const value = await storage.getValue();
  console.log(`Value on ${hre.network.name}: ${value.toString()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
