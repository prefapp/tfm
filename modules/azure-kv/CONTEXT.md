# azure-kv

Owns one Key Vault and its access policies.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**authorization model**:
`enable_rbac_authorization` picks between Azure RBAC and vault access policies. The two are mutually exclusive: `access_policies` entries are meaningless when RBAC is on.
_Avoid_: permissions (say which model)

**purge protection**:
`purge_protection_enabled` — once enabled it **cannot be disabled**, and a deleted vault cannot be purged before `soft_delete_retention_days` elapse. Treat it as one-way.

**access policy**:
A per-principal grant of key, secret and certificate permissions, used only in the non-RBAC model.
