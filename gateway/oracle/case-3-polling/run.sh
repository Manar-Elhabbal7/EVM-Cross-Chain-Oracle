#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../../" && pwd )"

echo "----------------------------------------------------"
echo "Case 3: Polling Sync"
echo "Description: Synchronization via periodic state checks."
echo "----------------------------------------------------"

# Start Oracle in background
cd "$SCRIPT_DIR"
RPC_A=$RPC_A RPC_B=$RPC_B PRIVATE_KEY=$PRIVATE_KEY ADDRESS_A=$ADDRESS_A ADDRESS_B=$ADDRESS_B node polling-sync.js > oracle.log 2>&1 &
ORACLE_PID=$!

echo "Oracle started in background (PID: $ORACLE_PID). Waiting 2s..."
sleep 2

echo "Step 1: Updating Chain A..."
cd "$PROJECT_ROOT/evm"
ADDRESS_A=$ADDRESS_A npx hardhat run scripts/update-value.js --network chainA > /dev/null

echo "Step 2: Waiting for polling detection (5s)..."
sleep 5

echo "Step 3: Verifying on Chain B..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B=$ADDRESS_B npx hardhat run scripts/verify.js --network chainB

# clean up oracle process
kill $ORACLE_PID
echo "Oracle stopped."
