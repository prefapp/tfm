# aws-rds

Owns an RDS instance, its subnet group and security group, and publishes its connection details.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**credential strategy**:
The three mutually exclusive ways the master password is handled: `manage_master_user_password` (RDS owns it in Secrets Manager), `use_secrets_manager` (this module writes the secret), or SSM parameters. Exactly one applies, and the choice decides which of the module's outputs and resources exist at all.

**connection parameter**:
One of the SSM parameters the module publishes for consumers — name, username, password, endpoint, host and port. Their paths are inputs (`db_*_ssm_name`) so consumers can agree on a convention.

**network discovery**:
The tag-lookup fallback: `vpc_id` / `subnet_ids` win, otherwise the VPC and subnets are found by `vpc_tag_*` and `subnet_tag_*`.
