# Cross-Chain Oracle Sync

A lightweight Node.js oracle service that synchronizes state between two Ethereum-compatible blockchains. This project demonstrates a simple event-driven synchronization pattern where changes on a "Source" chain (Chain A) are detected and propagated to a "Destination" chain (Chain B).

## Overview

The system consists of:
1.  **Smart Contract (`Storage.sol`)**: A simple contract deployed on both chains that stores a numeric value and emits a `ValueChanged` event whenever the value is updated.
2.  **Oracle Service (`oracle.js`)**: A Node.js application that:
    *   Polls Chain A for `ValueChanged` events.
    *   Extracts the new value from detected events.
    *   Submits a transaction to Chain B to update its state to match Chain A.

## Project Structure

```text
evm-cross-chain-oracle/
├── api/                   # Oracle Service (Node.js)
│   ├── oracle.js          # Core logic: Event listening & cross-chain relay
│   ├── .env               # Environment variables (RPCs, Keys, Addresses)
│   ├── .env.example       # Template for environment configuration
│   └── package.json       # Node.js dependencies (ethers, dotenv)
│
├── evm/                   # Smart Contracts & Development Environment
│   ├── contracts/
│   │   └── Storage.sol    # Smart contract with event-driven architecture
│   │
│   ├── scripts/
│   │   ├── deploy.js      # Automation for multi-chain deployment
│   │   ├── update-value.js # Trigger for testing Chain A events
│   │   └── verify.js      # Verification for Chain B state sync
│   │
│   ├── hardhat.config.cjs # Multi-network configuration
│   └── package.json       # EVM dependencies (hardhat, ethers)
│
├── .gitignore             # Excludes node_modules, .env, and build artifacts
├── README.md              # Project documentation & setup guide
└── test-sync.sh           # Fully automated end-to-end integration test
```

## Prerequisites

*   Node.js (v16+)
*   npm or yarn
*   Two Ethereum RPC endpoints (or two local Hardhat/Anvil instances)

## Setup

### 1. Install Dependencies

Install dependencies for both the oracle and the EVM environment:

```bash
# Install Oracle dependencies
cd api && npm install

# Install EVM dependencies
cd ../evm && npm install
```

### 2. Configure Environment

Create a `.env` file in the `api` directory based on `.env.example`:

```bash
cp api/.env.example api/.env
```

Edit `api/.env` with your RPC URLs and private key.

## Quick Start 

The easiest way to see the cross-chain sync in action is to run the automated demo script. This script starts two local blockchains, deploys the contracts, launches the oracle, and performs a test synchronization.

```bash
# Ensure dependencies are installed
cd api && npm install
cd ../evm && npm install
cd ..

# Run the full demo
chmod +x test-sync.sh
./test-sync.sh
```

The script will log its progress and confirm when the state has been successfully synced from Chain A to Chain B. You can inspect `evm/oracle.log` to see the oracle's internal activity.

## Manual Usage

If you prefer to run the components separately:

### 1. Start Local Blockchains
Open two terminals and run:
*   **Chain A:** `cd evm && npx hardhat node --port 8545`
*   **Chain B:** `cd evm && npx hardhat node --port 8546`

### 2. Deploy Contracts
```bash
cd evm
npx hardhat run scripts/deploy.js --network chainA
npx hardhat run scripts/deploy.js --network chainB
```
*Update `api/.env` with the outputted addresses.*

### 3. Start the Oracle
```bash
cd api
node oracle.js
```

### 4. Trigger Sync
```bash
cd evm
ADDRESS_A=<CONTRACT_ADDRESS> npx hardhat run scripts/update-value.js --network chainA
```

## How It Works

1.  The Oracle service initializes Ethers.js providers for both chains.
2.  It tracks the `lastBlock` processed on Chain A.
3.  Every 2 seconds, it checks if new blocks have been produced on Chain A.
4.  If new blocks exist, it queries for `ValueChanged` events in the range `[lastBlock + 1, currentBlock]`.
5.  For each event, it sends a `setValue` transaction to the contract on Chain B using the signer's private key.

## FAQ 
1. why is the address of the contract is the same in both chains?

2. why is chain b has the same value of chain a?

3. Describe the process happen when run `./test-sync.sh`

4. what is the smart contract ?

5. what is oracle make and hardhat?


## Resources I study from and Higly Recommend 

1. https://cryptozombies.io
  * start with this : https://cryptozombies.io/en/solidity


## Demo :
[demo.webm](https://github.com/user-attachments/assets/67ed15ba-b693-414d-bb69-9f07ee302db6)

  
