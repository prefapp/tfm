# azure-managed-redis

Owns an Azure Managed Redis instance, its access policy assignments and zero or more private endpoints.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**private endpoint**:
One entry in `private_endpoints`, a map of private-link NICs each placed in its own `subnet_name`. Its DNS zone is registered either by resolving `dns_private_zone_name` in the current subscription (typically `privatelink.redisenterprise.cache.azure.net`), or by passing an already-resolved `private_dns_zone_id` directly, which is how a zone from another subscription (e.g. one fetched in claims via a `ref`) is wired in. Leaving `private_endpoints` empty only skips private endpoint creation; public exposure is controlled independently by `managed_redis.public_network_access`.

**access policy assignment**:
A directory principal object ID granted a built-in access policy on the default database. This is the data-plane grant; RBAC on the resource is separate.

**Managed Redis**:
The Redis Enterprise-based service, distinct from `azure-redis-cache`, which owns the older Azure Cache for Redis.
_Avoid_: Redis Cache
