#!/bin/bash

STATE_FILE=".demo_state"
touch $STATE_FILE

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to draw progress bar
draw_progress_bar() {
    local duration=$1
    local sleep_interval=0.1
    local progress=0
    local block="█"
    
    while [ $(echo "$progress < 100" | bc -l) -ne 0 ]; do
        progress=$(echo "$progress + (100 / ($duration / $sleep_interval))" | bc -l)
        local filled=$(echo "$progress / 4" | bc)
        local empty=$((25 - filled))
        printf "\rProgress: ["
        for i in $(seq 1 $filled); do printf "$block"; done
        for i in $(seq 1 $empty); do printf " "; done
        printf "] %d%%" "${progress%.*}"
        sleep $sleep_interval
    done
    echo -e "\n"
}

check_status() {
    if grep -q "case-$1=done" "$STATE_FILE"; then
        echo -e "${GREEN}[DONE]${NC}"
    else
        echo -e "${YELLOW}[PENDING]${NC}"
    fi
}

mark_done() {
    sed -i "/case-$1/d" "$STATE_FILE"
    echo "case-$1=done" >> "$STATE_FILE"
}

check_all_done() {
    if [ $(grep -c "=done" "$STATE_FILE") -eq 4 ]; then
        echo "===================================================="
        echo "🎉 ALL SCENARIOS COMPLETED SUCCESSFULLY!"
        echo "===================================================="
        echo "  __  __   _   ___ _____ ___ ___ "
        echo " |  \/  | /_\ / __|_   _| __| _ \\"
        echo " | |\/| |/ _ \\\\__ \ | | | _||   /"
        echo " |_|  |_/_/ \_\___/ |_| |___|_|_\\"
        echo ""
        echo "       🎉 YOU ARE NOW A BLOCKCHAIN MASTER 🎉"
        echo "===================================================="
        # Optional: clear state after completion
        # > $STATE_FILE
    fi
}

PROJECT_ROOT=$(pwd)

setup_env() {
    # Start nodes if not running
    if ! lsof -i:8545 >/dev/null; then
        echo "Starting nodes..."
        cd "$PROJECT_ROOT/evm"
        npx hardhat node --port 8545 > /dev/null 2>&1 &
        PID_A=$!
        npx hardhat node --port 8546 > /dev/null 2>&1 &
        PID_B=$!
        sleep 5
    fi

    # Ensure addresses are exported
    cd "$PROJECT_ROOT/evm"
    export ADDRESS_A=$(npx hardhat run scripts/deploy.js --network chainA | grep "Storage deployed to:" | awk '{print $4}')
    export ADDRESS_B=$(npx hardhat run scripts/deploy.js --network chainB | grep "Storage deployed to:" | awk '{print $4}')
    export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    export RPC_A="http://127.0.0.1:8545"
    export RPC_B="http://127.0.0.1:8546"
    cd "$PROJECT_ROOT"
}

run_case() {
    local case_num=$1
    local case_name=$2
    local case_path=$3
    local case_dir=$(dirname "$case_path")
    local script_name=$(basename "$case_path")

    echo -e "\n${BLUE}🚀 Running Case $case_num: $case_name${NC}"
    setup_env
    draw_progress_bar 2
    
    chmod +x "$case_path"
    # Run in a subshell to isolate directory changes
    (cd "$case_dir" && ./"$script_name")
    
    mark_done $case_num
    echo -e "${GREEN}✅ Case $case_num finished!${NC}"
}

# Main Menu Logic
if [ "$1" == "--case" ]; then
    # Expand the wildcard to get the actual path
    case_path=$(ls gateway/oracle/case-$2-*/run.sh 2>/dev/null | head -n 1)
    
    if [ -z "$case_path" ]; then
        echo -e "${YELLOW}❌ Error: Case $2 not found.${NC}"
        exit 1
    fi

    case $2 in
        1) name="Manual Sync" ;;
        2) name="Event-Driven Sync" ;;
        3) name="Polling Sync" ;;
        4) name="Multi-Chain Sync" ;;
        *) name="Custom Case" ;;
    esac

    run_case "$2" "$name" "$case_path"
    check_all_done
    exit 0
fi

if [ "$1" == "--reset" ]; then
    > $STATE_FILE
    echo "State reset."
    exit 0
fi

clear
echo "===================================================="
echo "🚀 CROSS-CHAIN ORACLE DEMO SUITE"
echo "===================================================="
echo -n "1. Case 1: Manual Sync      " && check_status 1
echo -n "2. Case 2: Event-Driven     " && check_status 2
echo -n "3. Case 3: Polling Sync     " && check_status 3
echo -n "4. Case 4: Multi-Chain      " && check_status 4
echo "===================================================="
echo "Commands:"
echo "  ./run-all.sh --all        Run all cases sequentially"
echo "  ./run-all.sh --case <n>   Run a specific case (1-4)"
echo "  ./run-all.sh --reset      Reset progress"
echo "===================================================="

if [ "$1" == "--all" ]; then
    for i in {1..4}; do
        case $i in
            1) run_case 1 "Manual Sync" "gateway/oracle/case-1-manual/run.sh" ;;
            2) run_case 2 "Event-Driven" "gateway/oracle/case-2-event/run.sh" ;;
            3) run_case 3 "Polling Sync" "gateway/oracle/case-3-polling/run.sh" ;;
            4) run_case 4 "Multi-Chain" "gateway/oracle/case-4-multi/run.sh" ;;
        esac
    done
    check_all_done
fi
