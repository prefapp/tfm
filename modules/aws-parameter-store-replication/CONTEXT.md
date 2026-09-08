# aws-parameter-store-replication

Owns the Lambda and event wiring that copy SSM parameters into other accounts or regions.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**replication mode**:
One of three ways the Lambda is entered — EventBridge-driven, manual single-parameter invocation, or full sync. One function serves all three, told apart by event shape (see [ADR 0001](./docs/adr/0001-unified-lambda-for-all-replication-modes.md)).

**full sync**:
A sweep of every parameter matching the prefix. It runs only when the *event* carries `enable_full_sync` or `initial_run`; the `enable_full_sync` variable is an allow/deny guardrail, never a trigger (see [ADR 0003](./docs/adr/0003-full-sync-requires-explicit-event-flag.md)).

**destination**:
One target account/region pair in `destinations_json`, reached by assuming a role from `allowed_assume_roles`.

**delete gap**:
Deletes are deliberately not replicated, so a replica outlives the deletion of its source and stays a recovery point. Stale replicas are the accepted cost (see [ADR 0002](./docs/adr/0002-delete-events-not-replicated.md)).

**async failure visibility**:
The DLQ plus alarm path that catches asynchronous invocations failing after retries, which would otherwise be dropped silently (see [ADR 0004](./docs/adr/0004-async-failure-visibility-via-dlq.md)).
