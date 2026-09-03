# azure-vnet-and-subnet

Owns a virtual network, its subnets, the private DNS zones tied to it, and peerings from its side.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**local side**:
This module owns only the peerings declared *from* this VNet. A working peering needs both directions, so the remote side must be created by the remote VNet's own module instance.
_Avoid_: peering (implies both directions)

**private DNS zone**:
A zone created and linked by this module (`private_dns_zones`), as opposed to `existing_private_dns_zone_links`, which only adds a link to a zone someone else owns.

**subnet**:
Declared inside `virtual_network`, not as a separate input. Subnets and the VNet share one state, so a subnet change plans against the VNet.
