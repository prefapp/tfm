# Architecture Decision Records — aws-secretsmanager-replication

Module-scoped ADRs for `aws-secretsmanager-replication`. Decisions that span multiple modules go in the
root [`docs/adr/`](../../../../docs/adr/) instead; use the narrowest scope that
fully contains the decision.

Format and numbering: `NNNN-slug.md`, numbered sequentially per directory from
`0001`; add each new file to the list below in the same change. See
[`CONSTITUTION.md`](../../../../CONSTITUTION.md) §9 for when a decision earns an ADR.

- [0001 — Region prefix and `origin-region` tag encode the source region](./0001-origin-region-is-source-region.md)
- [0002 — A single Lambda handles all replication modes](./0002-single-lambda-for-all-replication-modes.md)
