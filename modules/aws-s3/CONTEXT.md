# aws-s3

Owns an S3 bucket and its policy, versioning, lifecycle and replication configuration.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**bucket ownership**:
`create_bucket` — false makes the module manage the configuration of an existing bucket named by `bucket` without owning its lifecycle. Destroying the module then leaves the bucket in place.

**public access block**:
The four `block_*` / `ignore_*` / `restrict_*` switches, plus the `bucket_public_access` shortcut that sets all of them. Blocking is the default; opening a bucket is an explicit act.

**replication side**:
A bucket is configured as `s3_replication_source` or `s3_replication_destination`, never both in one module instance. The source side is what creates the replication IAM role.

**default lifecycle rules**:
The baseline rules applied when `lifecycle_rules` is not given. Supplying `lifecycle_rules` replaces them rather than adding to them.
