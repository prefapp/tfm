# azure-resource-group

Owns one resource group.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**resource group**:
The container almost every other Azure module in this catalog places resources into, and the source of the tags they inherit through `tags_from_rg`.

**forced replacement**:
Both `name` and `location` force a new resource group. Changing either destroys everything inside it, so neither is a routine edit.
