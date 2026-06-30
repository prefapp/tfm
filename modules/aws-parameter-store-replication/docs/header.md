# **AWS Systems Manager Parameter Store Replication Terraform Module**

## Overview

This Terraform module provisions and manages a Lambda function for cross-account and cross-region replication of AWS Systems Manager Parameter Store parameters. It automates the deployment of the Lambda, IAM roles, permissions, and (optionally) EventBridge rules to trigger parameter replication on changes.

The module is designed for secure and automated parameter replication, supporting flexible configuration of destination accounts and regions. It is suitable for organizations that need to synchronize configuration parameters across multiple AWS environments for Disaster Recovery or multi-region scenarios.

> **Note:** This module is currently **not** compatible with GitHub Automated Provisioning Systems such as `ghaps` because it does not use the single top-level `config` input pattern.

## Key Features

- **Parameter Replication**: Automatically replicates parameters to one or more destination AWS accounts and/or regions.
- **Event-Driven**: Uses EventBridge to trigger replication when a parameter is created or updated (optional).
- **Customizable Destinations**: Configure multiple destination accounts and regions, each with its own IAM role and KMS key.
- **IAM Role Management**: Creates all necessary IAM roles and policies for Lambda execution and cross-account access.
- **Environment Variables**: Supports custom environment variables for advanced configuration.
- **Tag Replication**: Optionally replicates tags from the source parameter to the destination (controlled by the `enable_tag_replication` variable).
- **Parameter Type Support**: Handles String, StringList, and SecureString parameter types.

## Parameter Replication Logic

This module deploys a single Lambda function that handles multiple invocation modes:

1. **EventBridge Automatic Mode** (if `eventbridge_enabled = true`): Automatically triggers on SSM Parameter Store Create/Update events.
2. **Manual Single Parameter Mode**: Direct Lambda invocation with `{"parameter_name": "my-parameter"}` in the payload.
3. **Full Account Sync Mode** (if `enable_full_sync = true`): Direct Lambda invocation with `{"initial_run": true}` or `{"enable_full_sync": true}` to replicate all parameters in the source account.

The Lambda determines the source parameter based on the invocation mode:

- **Automatic**: extracts from the EventBridge event detail (`name` field).
- **Manual**: from the `parameter_name` field in the event payload.
- **Full sync**: enumerates all parameters via `describe_parameters()` and replicates each.

### Full Sync Scale and Timeout Considerations

Full sync currently runs sequentially inside a single Lambda invocation. The module default is `lambda_timeout = 600` seconds, and AWS Lambda has a hard maximum of `900` seconds.

For large parameter inventories (especially with multiple destination regions/accounts), full sync can time out mid-run. This module does not currently implement built-in continuation/resume semantics (for example, self-invocation with pagination state).

For DR bootstrap at larger scale, prefer one of these approaches:

- Increase timeout (up to 900s) and run in controlled batches/scopes.
- Re-run full sync iteratively until convergence.
- Use an external orchestrator (for example, Step Functions) for chunking/continuation and retry control.

You can also configure STS assumed-role session duration with `assume_role_duration_seconds` (default `3600`, valid range `900..43200`).
Note that the effective value cannot exceed the destination role `MaxSessionDuration`; if you set a higher value than the role allows, AWS STS `AssumeRole` will fail.

### Delete Event Behavior (Intentional)

For safety, this module intentionally replicates **Create/Update** events only. Delete events are not replicated by default:

- EventBridge rule filters operations to `Create` and `Update`.
- The Lambda handler ignores non-Create/Update Parameter Store change events.

This is a deliberate disaster-recovery design choice to avoid accidental destructive propagation across accounts/regions.

Operational consequence: destination accounts may accumulate parameters that were deleted in the source account. If you need destination cleanup, handle deletions through a separate controlled process.

### Async Failure Visibility (EventBridge)

EventBridge invokes Lambda asynchronously. Without explicit failure handling, events can be dropped after retries.

This module can provide built-in visibility for async failures when `eventbridge_enabled = true`:

- Lambda async invoke config (`aws_lambda_function_event_invoke_config`)
- On-failure destination to SQS DLQ
- CloudWatch alarms for Lambda async errors and DLQ visible messages

Relevant inputs:

- `async_failure_visibility_enabled` (default `true`)
- `lambda_async_maximum_retry_attempts` (default `2`, valid `0..2`)
- `replication_failure_alarm_actions` (list of ARNs, e.g. SNS topics)

Scope note: the `lambda_async_errors` alarm is intended for async EventBridge failure visibility. Manual/full-sync invocation paths may catch exceptions and return structured responses, which can avoid incrementing the Lambda `Errors` metric in the same way as unhandled async failures.

The **destination parameter name matches the source parameter name by default**. If `add_region_prefix_to_name = true`, the destination name is prefixed with the source region (for example, `/eu-west-1/my/parameter` for path names, or `eu-west-1-myparameter` for simple names).

### Destination Configuration Format

The destinations are configured via the `destinations_json` variable, which must be a JSON string with the following structure:

```json
{
  "DEST_ACCOUNT_ID": {
    "role_arn": "arn:aws:iam::DEST_ACCOUNT_ID:role/ReplicationRole",
    "regions": {
      "us-east-1": {
        "kms_key_arn": "arn:aws:kms:us-east-1:DEST_ACCOUNT_ID:key/xxxx"
      },
      "eu-west-1": {
        "kms_key_arn": "arn:aws:kms:eu-west-1:DEST_ACCOUNT_ID:key/yyyy"
      },
      "eu-north-1": {}
    }
  }
}
```

You can specify as many destination accounts and regions as needed. Each region may optionally specify a KMS key.

### KMS Key Selection

You can optionally specify a custom KMS key for each destination region in the `destinations_json` variable using the `kms_key_arn` field. If the value is omitted, the AWS managed key will be used.

```json
{
  "DEST_ACCOUNT_ID": {
    "role_arn": "arn:aws:iam::DEST_ACCOUNT_ID:role/ReplicationRole",
    "regions": {
      "eu-west-1": {
        "kms_key_arn": "arn:aws:kms:eu-west-1:DEST_ACCOUNT_ID:key/abcd-1234-efgh-5678"
      },
      "us-east-1": {}
    }
  }
}
```

- If `kms_key_arn` is set for a region, the replicated parameter will be encrypted with that KMS key (for SecureString parameters).
- If `kms_key_arn` is omitted for a region, the parameter will be encrypted using the default AWS managed key for Parameter Store in that region.

This allows you to mix and match custom and managed keys as needed for your security requirements.

### Tag Replication

By default, the Lambda always applies replication metadata tags (`origin-account`, `origin-region`, `latest-version`) to the destination parameter. When `enable_tag_replication = true`, it also copies source parameter tags and prunes tags that no longer exist on the source; when `enable_tag_replication = false`, only the metadata tags are applied.

## Important Note: Permissions

**Important:**
 The **destination replication role** (assumed by the Lambda in each destination account) must allow managing the destination parameter name produced by this module.

The IAM policy in the destination account must allow the appropriate ARN format:

- For simple destination names (for example, `myparameter`):

```
arn:aws:ssm:<region>:<account>:parameter/<destination_parameter_name>
```

- For path-style destination names (for example, `/eu-west-1/my/parameter`):

```
arn:aws:ssm:<region>:<account>:parameter<destination_parameter_name>
```

Where `<destination_parameter_name>` is determined by the module's naming logic:
- If `add_region_prefix_to_name = false` (default): matches the source parameter name.
- If `add_region_prefix_to_name = true`: region-prefixed, e.g., `/eu-west-1/my/parameter` (path-style) or `eu-west-1-myparameter` (simple name).

This allows the replication role to manage the destination parameter across all its versions.

For successful replication without access-denied warnings, the destination role should allow these SSM actions on the destination parameter ARN(s):

- `ssm:PutParameter` (required for value replication)
- `ssm:GetParameters` (required for destination existence probe and update-time tag operations)
- `ssm:AddTagsToResource` (required to apply desired tags on updates)
- `ssm:ListTagsForResource` and `ssm:RemoveTagsFromResource` (required to prune stale tags when `enable_tag_replication = true`)

If `enable_tag_replication = false`, the destination role can omit `ssm:ListTagsForResource` and `ssm:RemoveTagsFromResource`, but replication still requires `ssm:PutParameter`, `ssm:GetParameters` (existence probe), and `ssm:AddTagsToResource` (apply replication metadata tags on updates).

## Basic Usage

### Simple Cross-Region Replication

```hcl
module "parameter_replication" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-parameter-store-replication"

  name   = "my-app-parameters"
  prefix = "myorg"

  destinations_json = jsonencode({
    "123456789012" = {
      "role_arn" = "arn:aws:iam::123456789012:role/ParameterReplicationRole"
      "regions" = {
        "us-east-1" = {}
        "eu-west-1" = {}
      }
    }
  })

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Cross-Account Replication with EventBridge

```hcl
module "parameter_replication_eventbridge" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-parameter-store-replication"

  name   = "multi-account-parameters"
  prefix = "corp"

  eventbridge_enabled = true

  destinations_json = jsonencode({
    "111111111111" = {
      "role_arn" = "arn:aws:iam::111111111111:role/ParameterReplicationRole"
      "regions" = {
        "us-east-1" = {
          "kms_key_arn" = "arn:aws:kms:us-east-1:111111111111:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
      }
    }
    "222222222222" = {
      "role_arn" = "arn:aws:iam::222222222222:role/ParameterReplicationRole"
      "regions" = {
        "eu-west-1" = {}
      }
    }
  })

  tags = {
    Service = "configuration-sync"
  }
}
```
