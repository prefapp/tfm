# azure-public-prefix

Owns a public IP prefix — a contiguous block of public addresses.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**prefix length**:
How many addresses the block holds; a shorter length means a larger block. It cannot be changed after creation.
_Avoid_: subnet mask

**prefix vs address**:
This module owns the reserved *range*. Individual addresses are then allocated from it, typically by `azure-public-ip` or by a NAT gateway.
