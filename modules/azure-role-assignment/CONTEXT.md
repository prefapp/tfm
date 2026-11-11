# azure-role-assignment

Owns a set of Azure RBAC role assignments.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**assignment key**:
The map key of a `role_assignments` entry. It names the assignment for Terraform only and never appears in Azure, so renaming a key destroys and recreates the assignment.

**assignment**:
A principal, a role and a scope. All three together are the identity of the grant in Azure.
