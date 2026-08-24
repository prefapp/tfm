# azure-managed-redis

Owns an Azure Managed Redis instance, its access policy assignments and optional private endpoint.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**private endpoint**:
The optional private-link NIC placed in `subnet_name` and registered in `dns_private_zone_name` (typically `privatelink.redisenterprise.cache.azure.net`). Set `private_endpoint` to null to expose the instance publicly instead.

**access policy assignment**:
A directory principal object ID granted a built-in access policy on the default database. This is the data-plane grant; RBAC on the resource is separate.

**Managed Redis**:
The Redis Enterprise-based service, distinct from `azure-redis-cache`, which owns the older Azure Cache for Redis.
_Avoid_: Redis Cache
