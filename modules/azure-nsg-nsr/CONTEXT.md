# azure-nsg-nsr

Owns one network security group and its rules.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**NSG**:
Network Security Group — the container. It attaches to subnets or NICs and holds no rules of its own.

**NSR**:
Network Security Rule — one allow or deny entry inside the NSG, ordered by priority. Rules are separate resources here, so a rule can be changed without replacing the group.
_Avoid_: security rule, firewall rule
