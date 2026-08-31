# aws-backup

Owns an AWS Backup vault, the plans and selections that fill it, and the Lambda that replicates recovery points across accounts.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**backup vault**:
The `aws_backup_vault` this module owns, optionally encrypted with a caller-supplied KMS key. Its access policy is what lets a *source account* copy into it.

**plan rule**:
One entry of a plan: a schedule, a lifecycle, and zero or more copy actions.

**copy action**:
A rule fragment that copies a recovery point into another vault, in another region or account. `copy_action_default_values` supplies the defaults every copy action inherits.

**resource selection vs tag selection**:
The two ways a plan picks what to back up: by explicit resource ARN, or by tag match. A plan may use both, and they are separate `aws_backup_selection` resources.

**cross-account backup**:
The mode enabled by `enable_cross_account_backup`, which turns on the account-wide `aws_backup_global_settings` and deploys the replication Lambda. It is account-global state, so only one module instance per account should own it.

**source account**:
The account that copies backups *into* this vault. It is granted access through the vault policy, not through the plan.
