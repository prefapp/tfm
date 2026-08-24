# azure-private-dns-zone

Owns one private DNS zone and the virtual network links into it.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**virtual network link**:
A binding between the zone and one VNet, taken from the `vnet_ids` map. A zone with no links resolves for nobody.

**registration**:
`registration_enabled` — whether VMs in the linked VNet auto-register their names in the zone. Azure allows this on at most one link per VNet.
