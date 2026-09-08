# azure-vnet-peering

Owns **both** sides of a peering between two existing virtual networks.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**origin and destination**:
The two existing VNets, each looked up by name and resource group. The module creates neither — it only peers them.

**both directions**:
Unlike the peerings declared inside `azure-vnet-and-subnet`, this module owns the origin→destination *and* destination→origin resources, which is why each side needs its own peering name.
_Avoid_: one-way peering
