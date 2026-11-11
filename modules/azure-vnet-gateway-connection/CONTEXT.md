# azure-vnet-gateway-connection

Owns virtual network gateway connections — the tunnels themselves.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**connection**:
One tunnel: site-to-site, VNet-to-VNet or ExpressRoute. The gateways at each end are owned elsewhere (`azure-vnet-gateway`, `azure-localnet-gateway`); this module only joins them.

**shared key**:
The pre-shared secret of a site-to-site connection. It must match the value configured on the remote device, which is outside Terraform's view.
