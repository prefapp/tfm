# azure-localnet-gateway

Owns local network gateways — the on-premises side of a site-to-site VPN.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**local network gateway**:
An Azure object describing a **remote** network: its public endpoint and address space. Despite the name, it represents the far side of the tunnel, not anything in Azure.
_Avoid_: local network, on-prem gateway

**localnet**:
The input list; each entry becomes one gateway.
