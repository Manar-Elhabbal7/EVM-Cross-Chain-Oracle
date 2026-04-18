#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../../" && pwd )"

echo "----------------------------------------------------"
echo "Case 4: Multi-Chain Sync"
echo "Description: Propagation to multiple destination chains (Chain B and Chain C)."
echo "----------------------------------------------------"

if [ -z "$ADDRESS_A" ] || [ -z "$ADDRESS_B" ] || [ -z "$ADDRESS_C" ]; then
    echo "Error: ADDRESS_A, ADDRESS_B, and ADDRESS_C must be set."
    exit 1
fi

# Start Oracle in background
cd "$SCRIPT_DIR"
RPC_A=$RPC_A RPC_B=$RPC_B RPC_C=$RPC_C PRIVATE_KEY=$PRIVATE_KEY ADDRESS_A=$ADDRESS_A ADDRESS_B=$ADDRESS_B ADDRESS_C=$ADDRESS_C node multi-sync.js > oracle.log 2>&1 &
ORACLE_PID=$!

echo "Oracle started in background (PID: $ORACLE_PID). Waiting 2s..."
sleep 2

echo "Step 1: Updating Chain A..."
cd "$PROJECT_ROOT/evm"
ADDRESS_A=$ADDRESS_A npx hardhat run scripts/update-value.js --network chainA > /dev/null

echo "Step 2: Waiting for multi-sync (5s)..."
sleep 5

echo "Step 3: Verifying on Chain B..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B=$ADDRESS_B npx hardhat run scripts/verify.js --network chainB

echo "Step 4: Verifying on Chain C..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B=$ADDRESS_C npx hardhat run scripts/verify.js --network chainC

# Cleanup
kill $ORACLE_PID
echo "Oracle stopped."
