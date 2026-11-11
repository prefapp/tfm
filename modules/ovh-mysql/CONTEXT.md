# ovh-mysql

Owns an OVHcloud managed MySQL service, its private-network attachment and its databases. User provisioning and application credentials are intentionally outside this context.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**Managed MySQL service**:
An OVHcloud-operated MySQL cluster in a Public Cloud project and region.

**database**:
A logical MySQL database created inside the managed service.

**private-network attachment**:
The connection of each MySQL node to an existing Public Cloud private network and subnet.

**IP restriction**:
A CIDR allow-list controlling which client addresses can connect to the MySQL service.

**API-created database user**:
A database identity created through OVHcloud Console or API, with administrator-equivalent privileges; it is not suitable as an application account.

**SQL-managed application user**:
A MySQL identity created through SQL and granted only the privileges required by its application. It is not visible or manageable through the OVHcloud API.
