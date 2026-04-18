# Case 4: Multi-Chain Sync

This scenario demonstrates how a single update on a source chain (Chain A) is propagated to multiple destination networks (Chain B and Chain C).

### Flow:
1.  **Multi-Chain Listener**: The oracle listens for `ValueChanged` events on **Chain A**.
2.  **Broadcast**: Upon detecting an event, the oracle concurrently sends update transactions to both **Chain B** and **Chain C**.
3.  **Consistency**: This pattern ensures that state changes are synchronized across an entire ecosystem of connected blockchains.

### How to run:

```bash
./run-all.sh --case 4
```

### Verification:
The script will update the value on Chain A and then verify that both Chain B and Chain C have received the new state.
