# Delete events intentionally not replicated

The EventBridge rule filters only `Create` and `Update` events; `Delete` events are ignored. This is a deliberate DR safety choice: if the source account deletes parameters (accidentally or maliciously), replicas survive as a recovery point. The trade-off is that stale destination parameters accumulate and must be cleaned manually or via a separate process.
