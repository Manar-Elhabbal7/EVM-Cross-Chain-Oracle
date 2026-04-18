#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../../" && pwd )"

echo "----------------------------------------------------"
echo "Case 1: Manual Sync"
echo "Description: Manually trigger state propagation."
echo "----------------------------------------------------"

if [ -z "$ADDRESS_A" ] || [ -z "$ADDRESS_B" ]; then
    echo "Error: ADDRESS_A and ADDRESS_B must be set."
    exit 1
fi

echo "Step 1: Updating Chain A with a new random value..."
cd "$PROJECT_ROOT/evm"
ADDRESS_A=$ADDRESS_A npx hardhat run scripts/update-value.js --network chainA > /dev/null

echo "Step 2: Running manual-sync script..."
cd "$SCRIPT_DIR"
RPC_A=$RPC_A RPC_B=$RPC_B PRIVATE_KEY=$PRIVATE_KEY ADDRESS_A=$ADDRESS_A ADDRESS_B=$ADDRESS_B node manual-sync.js

echo "Step 3: Verifying on Chain B..."
cd "$PROJECT_ROOT/evm"
ADDRESS_B=$ADDRESS_B npx hardhat run scripts/verify.js --network chainB
