#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../../" && pwd )"

echo "----------------------------------------------------"
echo "🌐 CASE 4: MULTI-CHAIN SYNC"
echo "Description: Propagation to multiple destination contracts."
echo "----------------------------------------------------"

# Deploy second contract on Chain B
echo "Deploying second contract on Chain B..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B2=$(npx hardhat run scripts/deploy.js --network chainB | grep "Storage deployed to:" | awk '{print $4}')
echo "Destination 2 Address: $ADDRESS_B2"

# Start Oracle in background
cd "$SCRIPT_DIR"
RPC_A=$RPC_A RPC_B=$RPC_B PRIVATE_KEY=$PRIVATE_KEY ADDRESS_A=$ADDRESS_A ADDRESS_B1=$ADDRESS_B ADDRESS_B2=$ADDRESS_B2 node multi-sync.js > oracle.log 2>&1 &
ORACLE_PID=$!

echo "Oracle started in background (PID: $ORACLE_PID). Waiting 2s..."
sleep 2

echo "Step 1: Updating Chain A..."
cd "$PROJECT_ROOT/evm"
ADDRESS_A=$ADDRESS_A npx hardhat run scripts/update-value.js --network chainA > /dev/null

echo "Step 2: Waiting for multi-sync (5s)..."
sleep 5

echo "Step 3: Verifying on Destination 1 (Chain B)..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B=$ADDRESS_B npx hardhat run scripts/verify.js --network chainB

echo "Step 4: Verifying on Destination 2 (Chain B)..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B=$ADDRESS_B2 npx hardhat run scripts/verify.js --network chainB

# Cleanup
kill $ORACLE_PID
echo "Oracle stopped."
