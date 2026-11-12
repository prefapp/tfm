# Architecture Decision Records — ovh-container-registry

Module-scoped ADRs for `ovh-container-registry` and its `modules/harbor` submodule. Decisions that span multiple modules go in the
root [`docs/adr/`](../../../../docs/adr/) instead; use the narrowest scope that
fully contains the decision.

Format and numbering: `NNNN-slug.md`, numbered sequentially per directory from
`0001`; add each new file to the list below in the same change. See
[`CONSTITUTION.md`](../../../../CONSTITUTION.md) §9 for when a decision earns an ADR.

- [0001 — Local Harbor admin without OVHcloud IAM](./0001-local-harbor-admin-without-ovh-iam.md)
- [0002 — Harbor content in a separate state, via a submodule with its own provider](./0002-harbor-in-a-separate-state.md)
