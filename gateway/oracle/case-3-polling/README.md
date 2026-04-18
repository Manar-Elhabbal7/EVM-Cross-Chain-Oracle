# Case 3: Polling Sync

This scenario demonstrates synchronization using a periodic polling mechanism instead of events.

### Flow:
1.  **Periodic Check**: The oracle script calls `getValue()` on Chain A every 3 seconds.
2.  **Comparison**: It compares the current value with the last known value.
3.  **State Sync**: If a difference is detected, it propagates the new value to Chain B.

### How to run:
```bash
./run.sh
```
