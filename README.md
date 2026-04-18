# Cross-Chain Oracle Demo Suite 

This repository demonstrates four progressive levels of blockchain interoperability and state synchronization patterns between three EVM-compatible networks (Chain A, Chain B, and Chain C).

##  Architecture
The suite uses a **Source-Oracle-Destination** pattern. An off-chain relay (Oracle) monitors state changes on **Chain A** (Source) and propagates them to **Chain B** and **Chain C** (Destinations) using different architectural strategies.

## Project Structure
- `gateway/oracle/`: Implementation of the four demo cases.
- `evm/`: Shared Hardhat environment, Solidity contracts, and deployment scripts.
- `run-all.sh`: The master orchestration script for the demo suite.

---

## Demo Cases Summary

### Case 1: Manual Sync
*   **Strategy**: User-triggered.
*   **Flow**: Chain A → Chain B.
*   **Concept**: The most basic form of bridging. A script manually reads the current state from the source and writes it to the destination. Useful for one-time migrations or low-frequency updates.

### Case 2: Event-Driven Sync
*   **Strategy**: Real-time listening.
*   **Flow**: Chain A → Chain B.
*   **Concept**: Uses a WebSocket or JSON-RPC listener to react instantly to `ValueChanged` events. This is the industry standard for high-performance bridges and oracles.

### Case 3: Polling Sync
*   **Strategy**: Periodic checking.
*   **Flow**: Chain A → Chain B.
*   **Concept**: The oracle periodically queries the state of Chain A. This "pull" model is resilient to missed events and is used when event logs are unavailable or unreliable.

### Case 4: Multi-Chain Sync
*   **Strategy**: Broadcasting.
*   **Flow**: Chain A → **Chain B & Chain C**.
*   **Concept**: Demonstrates scalability. A single state change on the source chain is detected and broadcasted to multiple independent destination networks concurrently.

---

## Getting Started

### 1. Install Dependencies
Run the setup script to install all necessary Node.js packages for the EVM environment and each oracle case:
```bash
./gateway/setup.sh
```

### 2. Run the Demo Suite
The `./run-all.sh` script is the primary way to interact with the demo. It manages the local blockchain nodes (Hardhat), deploys contracts, and executes the oracle logic.

#### **Run the Interactive Menu**
Simply execute the script without arguments to see the current progress and available commands:
```bash
./run-all.sh
```

#### **Run All Cases Sequentially**
To run the entire suite from start to finish:
```bash
./run-all.sh --all
```

#### **Run a Specific Case**
To run or re-run a specific scenario (1-4):
```bash
./run-all.sh --case 1
./run-all.sh --case 4
```

#### **Reset Progress**
Clear the completion state if you want to restart the demo from scratch:
```bash
./run-all.sh --reset
```

---

##  Troubleshooting
*   **Port Conflicts**: The demo uses ports `8545`, `8546`, and `8547`. Ensure no other services are using these.
*   **Logs**: If a case fails, check the `oracle.log` within the specific case directory (e.g., `gateway/oracle/case-4-multi/oracle.log`) for detailed error messages.

---
## Purpose

This project is an educational demo for me and others to explore blockchain interoperability, oracle systems, and cross-chain state synchronization in EVM networks.

It is inspired by `Hyperledger Cacti` and `cacti-demos` Repo .
