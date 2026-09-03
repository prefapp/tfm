# azure-disks

Owns a set of managed disks in one resource group, and optionally one role assignment over them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**disk list**:
`disks` — every disk this module owns. They share the resource group, location and tags; a disk needing different values belongs in another instance.

**role assignment**:
The optional single grant (`assign_role`, `role_definition_name`, `principal_id`) applied over the disks. One principal and one role for the whole set, not per disk.
