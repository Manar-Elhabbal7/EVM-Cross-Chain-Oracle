# Case 1: Manual Sync

In this scenario, the user manually triggers the synchronization between Chain A and Chain B.

### Flow:
1.  **Update Chain A**: A value is changed on Chain A.
2.  **Manual Trigger**: The `manual-sync.js` script is executed.
3.  **Read & Write**: The script reads the state from Chain A and sends a transaction to Chain B to match the state.

### How to run:

```bash
./run-all.sh --case 1
```
