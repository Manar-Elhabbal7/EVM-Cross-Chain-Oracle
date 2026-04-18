# Cross-Chain Oracle Demo Suite 🚀

This repository demonstrates four progressive levels of blockchain interoperability and state synchronization patterns between EVM-compatible networks.

##  Architecture
The suite uses a **Source-Oracle-Destination** pattern. An off-chain relay (Oracle) monitors state changes on **Chain A** and propagates them to **Chain B** using different architectural approaches.

## Project Structure
- `gateway/oracle/`: Contains the four progressive demo cases.
- `evm/`: Shared Hardhat environment and Solidity contracts.
- `run-all.sh`: Master script to run the entire suite automatically.

##  Demo Cases

### Case 1: Manual Sync 
A user-triggered script that reads state from Chain A and writes to Chain B. Demonstrates the most basic form of state bridging.

### Case 2: Event-Driven Sync .
A real-time listener that reacts to blockchain events (`ValueChanged`) for immediate synchronization.

### Case 3: Polling Sync 
An oracle that periodically checks state on Chain A, demonstrating an alternative design when events are unavailable or unreliable.

### Case 4: Multi-Chain Sync 
A single update on Chain A is broadcasted to multiple destination contracts, showcasing scalability.

##  How to Run

1.  **Setup Dependencies**:
    ```bash
    ./gateway/setup.sh
    ```

2.  **Run All Cases**:
    ```bash
    ./run-all.sh
    ```

---
🎉 **Built to explore the future of interoperable blockchains.**
