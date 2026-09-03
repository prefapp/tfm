# mongodb-atlas-project

Owns a MongoDB Atlas project, its database users and its IP access list.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**project**:
The Atlas container for clusters, users and network rules, created inside `org_id`. Clusters live in it but are owned by `mongodb-atlas-cluster`, in a separate state.

**database user**:
An Atlas-managed credential scoped to this project. The password is generated with `random_password`; it is not an input.

**whitelist IP**:
An `mongodbatlas_project_ip_access_list` entry — a source address allowed to reach the project's clusters. Private Link is the alternative path and bypasses this list.
_Avoid_: firewall rule
