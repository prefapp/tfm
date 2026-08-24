# aws-kms

Owns one KMS key, its alias, and its replicas in other regions.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**primary key vs replica key**:
The key created in `aws_region` is the primary; one `aws_kms_replica_key` is created per entry of `aws_regions_replica`. Replicas exist only when `multiregion` is true.

**alias prefix**:
`kms_alias_prefix` — the string prepended to `alias`, giving the full name `alias/{prefix}{alias}`. The prefix is how keys are namespaced per project or environment.

**role tier**:
The three permission levels the key policy grants: `administrator_role_name` (manage the key), `user_roles_with_read_write` (encrypt and decrypt), `user_roles_with_read` (decrypt only). Setting one to null omits that statement entirely.

**via_service**:
The list of AWS services allowed to use the key on a principal's behalf, expressed as a `kms:ViaService` condition. It narrows *how* the key is used, not *who* uses it.
