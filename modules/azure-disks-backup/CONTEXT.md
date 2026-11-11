# azure-disks-backup

Owns a Data Protection backup vault dedicated to managed disks, with its policies and instances.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**vault redundancy**:
`redundancy` plus `soft_delete` and `retention_duration_in_days` — the vault-level durability settings. Soft delete beyond the free 14 days is billable.

**policy vs instance**:
A *policy* defines schedule and retention; an *instance* binds one policy to one disk.

**operator role assignment**:
The module grants the vault's identity the rights it needs over the disks. Without it, backup instances are created but every backup job fails.
