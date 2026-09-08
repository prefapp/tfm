# azure-customrole

Owns one custom RBAC role definition.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**assignable scope**:
A scope where the role may be assigned. The **first** entry is special: it also becomes the scope the definition itself lives at, which decides who can see and manage the role.

**permissions block**:
The `actions` / `not_actions` / `data_actions` / `not_data_actions` sets. Control-plane actions and data-plane actions are separate lists and do not imply one another.
