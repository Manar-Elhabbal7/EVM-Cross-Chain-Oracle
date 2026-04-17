import hre from "hardhat";

async function main() {
  const contractAddress = process.env.ADDRESS_A; 
  if (!contractAddress) {
    console.error("Please provide ADDRESS_A in environment or edit script");
    process.exit(1);
  }

  const newValue = Math.floor(Math.random() * 100);
  const Storage = await hre.ethers.getContractFactory("Storage");
  const storage = Storage.attach(contractAddress);

  console.log(`Updating value on Chain A (${contractAddress}) to: ${newValue}`);
  const tx = await storage.setValue(newValue);
  await tx.wait();

  console.log(`Transaction confirmed: ${tx.hash}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
