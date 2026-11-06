# ovh-container-registry

Owns an OVHcloud Managed Private Registry, its local Harbor admin and that admin's KMS secret. The `modules/harbor` submodule owns the Harbor projects and robot accounts inside the registry, in a separate state.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**Managed Private Registry**:
An OVHcloud-managed Harbor instance in a Public Cloud project and region.
_Avoid_: MPR, container registry (ambiguous with other registries)

**Harbor admin**:
The local Harbor user created through the OVHcloud API, whose credentials in OKMS configure the `harbor` provider of the submodule.
_Avoid_: root user, OVH user

**global robot**:
A system-level Harbor robot account with `read` or `write` access to every project, present and future.

**project robot**:
A Harbor robot account scoped to one project.

**access level**:
`read` grants pull; `write` grants pull and push. The only two levels a robot can have.

**IP restriction**:
An allow-list of CIDRs on either the management plane (Harbor UI and API) or the registry endpoint (push and pull). An empty list means no restriction.
