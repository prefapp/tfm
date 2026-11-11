# azure-mi

Owns a user-assigned managed identity and everything attached to it: role assignments, Key Vault access policies and federated credentials.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**user-assigned identity**:
An identity object with its own lifecycle, assignable to several resources. Distinct from a system-assigned identity, which dies with its resource and cannot be managed here.

**federated credential**:
A trust that lets an external workload — typically a Kubernetes service account — get tokens as this identity with no secret. `audience` is the token audience the issuer must present.

**rbac vs access_policies**:
Two separate grant paths: `rbac` for Azure role assignments, `access_policies` for a Key Vault still using the access-policy model.
