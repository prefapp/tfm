# azure-redis-cache

Owns an Azure Cache for Redis instance and zero or more private endpoints.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**Azure Cache for Redis**:
The classic Redis service this module owns, distinct from `azure-managed-redis`, which owns the newer Redis Enterprise-based service.
_Avoid_: Managed Redis

**private endpoint**:
One entry in `private_endpoints`, a map of private-link NICs each placed in its own `subnet_name`. Its DNS zone is registered either by resolving `dns_private_zone_name` in the current subscription, or by passing an already-resolved `private_dns_zone_id` directly (e.g. a zone from another subscription fetched in claims via a `ref`). Without any entries, the cache is reachable over its public endpoint.
