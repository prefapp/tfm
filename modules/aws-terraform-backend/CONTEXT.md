# aws-terraform-backend

Owns the S3 bucket and DynamoDB table that store and lock Terraform state for other stacks, plus the roles that reach them.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**state bucket**:
The versioned, encrypted S3 bucket at `tfstate_bucket_name` holding state objects under `tfstate_object_prefix`. This module is what makes the kernel term *state boundary* real for its consumers.

**locks table**:
The DynamoDB table backing Terraform state locking. One table serves every workspace using the bucket.

**backend access role**:
`tfbackend_access_role_name` — the role a consuming account assumes to read and write state. `backend_extra_roles` widens who may assume it.

**bootstrap template**:
The CloudFormation template the module can generate and upload so a client account can create its own admin role. It is a chicken-and-egg helper: it exists to be applied outside Terraform, before this backend can be used.
