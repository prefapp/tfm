# azure-redis-cache

Owns an Azure Cache for Redis instance and its optional private endpoint.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**Azure Cache for Redis**:
The classic Redis service this module owns, distinct from `azure-managed-redis`, which owns the newer Redis Enterprise-based service.
_Avoid_: Managed Redis

**private endpoint**:
The optional private-link NIC placed in `subnet_name` and registered in `dns_private_zone_name`. Without it the cache is reachable over its public endpoint.
