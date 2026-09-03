# azure-nat-gateway

Owns a NAT gateway and its associations to a public IP and a subnet.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**association**:
The two bindings that make a NAT gateway useful: one to a public IP, one to a subnet. Both are separate resources, so a gateway can exist attached to neither.

**idle timeout**:
`nat_gateway_timeout` — how long an idle outbound flow is kept. Raising it consumes SNAT ports for longer.
