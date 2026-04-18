# Case 2: Event-Driven Sync

This scenario demonstrates real-time synchronization using blockchain events.

### Flow:
1.  **Event Listener**: The oracle script listens for the `ValueChanged` event on Chain A.
2.  **Trigger**: An update occurs on Chain A, emitting an event.
3.  **Real-Time Sync**: The oracle detects the event immediately and propagates the change to Chain B.

### How to run:

```bash
./run-all.sh --case 2
```
