# ovh-postgresql

Owns one OVHcloud Public Cloud Databases for PostgreSQL cluster, its databases, PostgreSQL users, PgBouncer connection pools, and their connection credentials in an existing OKMS. The selected private network and subnet are existing infrastructure.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**managed cluster**:
An OVHcloud-managed PostgreSQL service, configured in one region and attached to one project.

**network region**:
The OpenStack region identifier of the existing private network and subnet; OVHcloud may label it differently from the Managed Database service region.

**connection pool**:
A managed PgBouncer endpoint for one declared database, with a selected pooling mode and optional user restriction.

**required extension**:
An extension name checked against the OVHcloud-supported catalogue and documented PostgreSQL version constraints. The module does not execute `CREATE EXTENSION`.

**direct connection secret**:
An OKMS JSON secret containing the direct endpoint, database, username and generated password for one declared user.

**pool connection secret**:
An OKMS JSON secret containing the pool connection URI. The URI is sensitive and is never exposed as a module output.

**maintained offer catalogue**:
A module-owned snapshot of stable PostgreSQL private-network offers, used to validate version, plan, region, flavor and disk range/increment together during plan; it may become stale as OVHcloud changes availability.
