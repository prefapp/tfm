# azure-oidc

Owns the Entra ID applications and federated credentials that let external workloads authenticate into a subscription, declared in one YAML file.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**data file**:
The YAML document at `data` that declares the applications, their federated credentials and their role assignments. It is the module's single source of truth.
_Avoid_: config (that name is reserved for the ghaps contract)

**federated credential**:
The issuer/subject/audience triple a workload's token must match to be accepted as the application. It replaces a client secret, so nothing needs rotating.
