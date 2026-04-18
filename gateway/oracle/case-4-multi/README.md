# Case 4: Multi-Chain Sync

This scenario demonstrates how a single update on a source chain can be propagated to multiple destination contracts or networks.

### Flow:
1.  **Multi-Destination Listener**: The oracle listens for events on Chain A.
2.  **Broadcast**: Upon detecting an event, the oracle sends update transactions to multiple destination contracts.
3.  **Scalability**: This pattern shows how the oracle can scale to keep many disparate systems in sync.

### How to run:
```bash
./run.sh
```
