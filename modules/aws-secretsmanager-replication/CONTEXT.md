# aws-secretsmanager-replication

Owns the Lambda, CloudTrail and event wiring that copy Secrets Manager secrets into other regions or accounts.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**replication mode**:
EventBridge-driven, manual single-secret (`secret_id`), or full account sync — one Lambda for all three, told apart by event shape. The separate automatic/manual Lambdas were removed in v2.0.0 (see [ADR 0002](./docs/adr/0002-single-lambda-for-all-replication-modes.md)).

**origin region**:
The **source** region of a secret. It is what the name prefix and the `origin-region` tag record — not the region the replica lives in — so a replica can always be traced home (see [ADR 0001](./docs/adr/0001-origin-region-is-source-region.md)).
_Avoid_: target region, destination region

**destination**:
One target account/region pair in `destinations_json`, reached by assuming a role from `allowed_assume_roles`.

**trail bucket**:
The S3 bucket behind the CloudTrail that delivers Secrets Manager API events. It may be supplied (`s3_bucket_arn`) or created by the module when `allow_auto_create_cloudtrail_bucket` permits it; `manage_s3_bucket_policy` decides who owns its policy.
