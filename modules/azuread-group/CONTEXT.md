# azuread-group

Owns an Entra ID security group, its membership, and the role assignments and PIM policy attached to it.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**subscription role vs directory role**:
Two different grant planes: `subscription_roles` are Azure RBAC roles over a subscription (`azurerm`), `directory_roles` are Entra ID roles over the tenant (`azuread`). A group can hold both, and they are never interchangeable.
_Avoid_: role (say which plane)

**PIM**:
Privileged Identity Management — when `enable_pim` is on, membership becomes *eligible* rather than permanent, and must be activated for a bounded time. This changes what being a member means, not just how it is audited.

**eligible vs active assignment**:
Under PIM, an *eligible* assignment can be activated by the member; an *active* one is already in force. The module can create both schedules.

**activation constraint**:
`default_pim_duration`, `pim_maximum_duration_hours`, `expiration_required` and `pim_require_justification` — the rules a member must satisfy to activate. They live in the group's role management policy, not in the assignment.

**assignable_to_role**:
Whether the group may hold directory roles at all. It cannot be changed after the group is created.
