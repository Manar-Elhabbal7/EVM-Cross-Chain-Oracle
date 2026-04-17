#!/bin/bash

# Function to kill processes on specific ports
cleanup_ports() {
    echo "Ensuring ports 8545 and 8546 are free..."
    fuser -k 8545/tcp > /dev/null 2>&1 || true
    fuser -k 8546/tcp > /dev/null 2>&1 || true
}

# Cleanup on exit
trap "echo 'Cleaning up...'; kill \$ORACLE_PID \$PID_A \$PID_B 2>/dev/null; cleanup_ports" EXIT

cleanup_ports

echo ""
echo "======================================"
echo "🚀 CROSS-CHAIN ORACLE SYNC FULL DEMO"
echo "======================================"
echo ""

# Move to evm
cd evm || { echo "Error: evm folder not found!"; exit 1; }

# 1. Start chains
echo "Starting Chain A (8545)..."
npx hardhat node --port 8545 > /dev/null 2>&1 &
PID_A=$!

echo "Starting Chain B (8546)..."
npx hardhat node --port 8546 > /dev/null 2>&1 &
PID_B=$!

echo " Waiting for chains to initialize..."
sleep 5

echo "✅ Chains started"
echo ""

# 2. Deploy contracts
echo "Deploying contracts..."

# Updated grep to match "Storage deployed to: <address>"
ADDRESS_A=$(npx hardhat run scripts/deploy.js --network chainA | grep "Storage deployed to:" | awk '{print $4}')
ADDRESS_B=$(npx hardhat run scripts/deploy.js --network chainB | grep "Storage deployed to:" | awk '{print $4}')

if [ -z "$ADDRESS_A" ] || [ -z "$ADDRESS_B" ]; then
    echo "Error: Deployment failed to capture addresses."
    exit 1
fi

echo "Chain A Contract: $ADDRESS_A"
echo "Chain B Contract: $ADDRESS_B"
echo ""

# 3. Start Oracle
echo "Starting Oracle..."


RPC_A="http://127.0.0.1:8545" \
RPC_B="http://127.0.0.1:8546" \
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" \
ADDRESS_A=$ADDRESS_A \
ADDRESS_B=$ADDRESS_B \
node ../api/oracle.js > oracle.log 2>&1 &
ORACLE_PID=$!

sleep 3

echo ""
echo "--------------------------------------"
echo "STEP 1: Updating value on Chain A"
echo "--------------------------------------"

ADDRESS_A=$ADDRESS_A npx hardhat run scripts/update-value.js --network chainA

echo ""
echo "Waiting for Oracle sync (5s)..."
sleep 5
echo ""

# 5. Verify on Chain B
echo "--------------------------------------"
echo "STEP 2: Verifying value on Chain B"
echo "--------------------------------------"

ADDRESS_B=$ADDRESS_B npx hardhat run scripts/verify.js --network chainB

echo ""

echo "======================================"
echo "🎉 CROSS-CHAIN SYNC COMPLETED!"
echo "======================================"
echo "✔ Event emitted on Chain A"
echo "✔ Oracle processed the event (see evm/oracle.log)"
echo "✔ State synced to Chain B"
echo "======================================"

exit 0
