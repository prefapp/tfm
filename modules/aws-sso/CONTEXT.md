# aws-sso

Owns IAM Identity Center users, groups, permission sets and account assignments, all declared in one YAML file.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**data file**:
The YAML document at `data_file` that declares the whole SSO topology. It is the module's single source of truth — inputs other than the store identifiers do not exist.
_Avoid_: config (that name is reserved for the ghaps contract), tfvars

**permission set**:
A named set of policies (managed, customer-managed or inline) that becomes a role once assigned to an account.

**account assignment**:
The binding of a principal (user or group) to a permission set in one account. Assignments are what actually grant access; a permission set alone grants nothing.
