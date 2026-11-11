# azure-vnet-gateway

Owns a virtual network gateway (VPN) and its NAT rules.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**VPN gateway**:
The `azurerm_virtual_network_gateway` this module owns, including its point-to-site configuration. Creation and SKU changes take tens of minutes — plans are slow by nature here.

**P2S config**:
The point-to-site part of the `vpn` object: client address pool, protocols and authentication. Distinct from the site-to-site *connections*, which `azure-vnet-gateway-connection` owns.

**NAT rule**:
An address translation applied on the gateway, needed when the two sides of a tunnel use overlapping address spaces.
