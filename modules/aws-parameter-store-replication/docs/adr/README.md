# Architecture Decision Records — aws-parameter-store-replication

Module-scoped ADRs for `aws-parameter-store-replication`. Decisions that span multiple modules go in the
root [`docs/adr/`](../../../../docs/adr/) instead; use the narrowest scope that
fully contains the decision.

Format and numbering: `NNNN-slug.md`, numbered sequentially per directory from
`0001`; add each new file to the list below in the same change. See
[`CONSTITUTION.md`](../../../../CONSTITUTION.md) §9 for when a decision earns an ADR.

- [0001 — One Lambda handles EventBridge, manual and full-sync modes](./0001-unified-lambda-for-all-replication-modes.md)
- [0002 — Delete events are intentionally not replicated](./0002-delete-events-not-replicated.md)
- [0003 — Full sync requires an explicit event flag](./0003-full-sync-requires-explicit-event-flag.md)
- [0004 — Async failure visibility via DLQ and alarms](./0004-async-failure-visibility-via-dlq.md)
