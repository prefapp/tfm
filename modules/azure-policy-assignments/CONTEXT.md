# azure-policy-assignments

Owns Azure Policy assignments at whichever scope each one names.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**scope**:
What decides which resource type is created: management group, subscription, resource group or a single resource. One list can mix all four.

**assignment**:
The binding of a policy definition or initiative to a scope. It is what makes a definition take effect; a definition alone does nothing.
