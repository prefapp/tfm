<!-- BEGIN_TF_DOCS -->
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

### Destination Role Trust Policy

The destination replication role is assumed by this module's Lambda via `sts:AssumeRole`. Its **trust policy must allow the source Lambda execution role as principal**, otherwise every replication fails with `AccessDenied` on the `AssumeRole` operation before any parameter is written.

Use the specific source role ARN as the principal (exposed by the module's `lambda_replication_role_arn` output):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<SOURCE_ACCOUNT_ID>:role/<PREFIX>-<NAME>-replication-role"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Note that the effective session duration is capped by the destination role's `MaxSessionDuration`; see the `assume_role_duration_seconds` note above.

### Destination Role SSM Permissions

For successful replication without access-denied warnings, the destination role should allow these SSM actions on the destination parameter ARN(s):

- `ssm:PutParameter` (required for value replication)
- `ssm:GetParameters` (required for destination existence probe and update-time tag operations)
- `ssm:AddTagsToResource` (required to apply desired tags on updates)
- `ssm:ListTagsForResource` and `ssm:RemoveTagsFromResource` (required to prune stale tags when `enable_tag_replication = true`)

If `enable_tag_replication = false`, the destination role can omit `ssm:ListTagsForResource` and `ssm:RemoveTagsFromResource`, but replication still requires `ssm:PutParameter`, `ssm:GetParameters` (existence probe), and `ssm:AddTagsToResource` (apply replication metadata tags on updates).

### Destination Role KMS Permissions

KMS permissions on the destination role are only required when a region's `kms_key_arn` points to a **customer-managed key** (CMK) used for `SecureString` parameters. In that case the destination role needs these actions scoped to the destination key ARN:

- `kms:Encrypt`
- `kms:GenerateDataKey`
- `kms:DescribeKey`

If `kms_key_arn` is omitted (AWS-managed `alias/aws/ssm` key), no extra KMS grant is needed. The destination role does not need `kms:Decrypt`, because the existence probe reads without decryption.

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.50 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.50 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_replication"></a> [lambda\_replication](#module\_lambda\_replication) | terraform-aws-modules/lambda/aws | ~> 7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.parameter_store_api_calls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_metric_alarm.lambda_async_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_async_failure_dlq_visible](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_role.lambda_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_async_failure_dlq_send](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_ssm_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_sts_assume_destinations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function_event_invoke_config.replication_async](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sqs_queue.lambda_async_failure_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.lambda_async_failure_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_async_failure_dlq_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_region_prefix_to_name"></a> [add\_region\_prefix\_to\_name](#input\_add\_region\_prefix\_to\_name) | If true, the destination parameter name is region-prefixed.<br/>For simple names: "myparameter" -> "us-east-1-myparameter".<br/>For path-style names: "/my/parameter" -> "/us-east-1/my/parameter".<br/>If false, the original name is used. Default: false.<br/>This helps avoid collisions if you replicate parameters with the same name from multiple regions. | `bool` | `false` | no |
| <a name="input_allowed_assume_roles"></a> [allowed\_assume\_roles](#input\_allowed\_assume\_roles) | Additional IAM role ARNs the Lambda is allowed to assume (destination role\_arn values from destinations\_json are always included). | `list(string)` | `[]` | no |
| <a name="input_assume_role_duration_seconds"></a> [assume\_role\_duration\_seconds](#input\_assume\_role\_duration\_seconds) | Duration (in seconds) for STS AssumeRole sessions used to access destination accounts. Must be between 900 and 43200 seconds, and cannot exceed the destination role MaxSessionDuration. | `number` | `3600` | no |
| <a name="input_async_failure_visibility_enabled"></a> [async\_failure\_visibility\_enabled](#input\_async\_failure\_visibility\_enabled) | Whether to create async failure visibility resources (Lambda async failure destination DLQ and CloudWatch alarms) when EventBridge is enabled. | `bool` | `true` | no |
| <a name="input_destinations_json"></a> [destinations\_json](#input\_destinations\_json) | JSON describing accounts, regions and KMS keys for replication | `string` | n/a | yes |
| <a name="input_enable_full_sync"></a> [enable\_full\_sync](#input\_enable\_full\_sync) | If true, the replication Lambda is granted ssm:DescribeParameters on all resources to support full-account sync. Set to false for strict least-privilege. | `bool` | `false` | no |
| <a name="input_enable_tag_replication"></a> [enable\_tag\_replication](#input\_enable\_tag\_replication) | Whether to copy/prune *source* tags from the source parameter. Replication metadata tags (origin-account, origin-region, latest-version) are always applied. Terraform also uses this to conditionally grant source tag-read permissions (`ssm:ListTagsForResource`). | `bool` | `true` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Additional environment variables passed to the Lambda | `map(string)` | `{}` | no |
| <a name="input_eventbridge_enabled"></a> [eventbridge\_enabled](#input\_eventbridge\_enabled) | Whether to create the EventBridge rule that triggers the Lambda | `bool` | `false` | no |
| <a name="input_lambda_async_maximum_retry_attempts"></a> [lambda\_async\_maximum\_retry\_attempts](#input\_lambda\_async\_maximum\_retry\_attempts) | Maximum retry attempts for asynchronous Lambda invocations (valid range: 0..2). | `number` | `2` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Lambda memory in MB | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | `600` | no |
| <a name="input_manual_replication_enabled"></a> [manual\_replication\_enabled](#input\_manual\_replication\_enabled) | DEPRECATED: Kept for backward compatibility. Manual replication is now always available through the unified Lambda. This variable no longer has any effect. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the Lambda and associated resources | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use for naming resources. | `string` | n/a | yes |
| <a name="input_replication_failure_alarm_actions"></a> [replication\_failure\_alarm\_actions](#input\_replication\_failure\_alarm\_actions) | List of ARNs (for example SNS topics) to notify when replication failure alarms trigger. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | ARN of the EventBridge rule (if created) |
| <a name="output_lambda_async_errors_alarm_arn"></a> [lambda\_async\_errors\_alarm\_arn](#output\_lambda\_async\_errors\_alarm\_arn) | ARN of the async errors CloudWatch alarm (if created) |
| <a name="output_lambda_async_failure_dlq_alarm_arn"></a> [lambda\_async\_failure\_dlq\_alarm\_arn](#output\_lambda\_async\_failure\_dlq\_alarm\_arn) | ARN of the async failure DLQ visibility CloudWatch alarm (if created) |
| <a name="output_lambda_async_failure_dlq_arn"></a> [lambda\_async\_failure\_dlq\_arn](#output\_lambda\_async\_failure\_dlq\_arn) | ARN of the async failure DLQ for replication Lambda (if created) |
| <a name="output_lambda_async_failure_dlq_url"></a> [lambda\_async\_failure\_dlq\_url](#output\_lambda\_async\_failure\_dlq\_url) | URL of the async failure DLQ for replication Lambda (if created) |
| <a name="output_lambda_automatic_replication_arn"></a> [lambda\_automatic\_replication\_arn](#output\_lambda\_automatic\_replication\_arn) | DEPRECATED: Use lambda\_replication\_arn. ARN of the replication Lambda function |
| <a name="output_lambda_automatic_replication_role_arn"></a> [lambda\_automatic\_replication\_role\_arn](#output\_lambda\_automatic\_replication\_role\_arn) | DEPRECATED: Use lambda\_replication\_role\_arn. IAM role ARN for the replication Lambda |
| <a name="output_lambda_manual_replication_arn"></a> [lambda\_manual\_replication\_arn](#output\_lambda\_manual\_replication\_arn) | DEPRECATED: Use lambda\_replication\_arn. ARN of the replication Lambda function |
| <a name="output_lambda_manual_replication_role_arn"></a> [lambda\_manual\_replication\_role\_arn](#output\_lambda\_manual\_replication\_role\_arn) | DEPRECATED: Use lambda\_replication\_role\_arn. IAM role ARN for the replication Lambda |
| <a name="output_lambda_replication_arn"></a> [lambda\_replication\_arn](#output\_lambda\_replication\_arn) | ARN of the unified replication Lambda function |
| <a name="output_lambda_replication_role_arn"></a> [lambda\_replication\_role\_arn](#output\_lambda\_replication\_role\_arn) | IAM role ARN for the replication Lambda |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store-replication/_examples):

- [Basic Replication](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store-replication/_examples/basic) – Replicate parameters to another AWS account or region
- [EventBridge with KMS](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store-replication/_examples/existing\_resources) – Event-driven replication with KMS encryption per destination region

## Remote resources

- Terraform: https://www.terraform.io/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- AWS Systems Manager Parameter Store: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
- aws\_ssm\_parameter: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
- AWS Lambda: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
- aws\_lambda\_function: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
- AWS EventBridge: https://docs.aws.amazon.com/eventbridge/latest/userguide/what-is-amazon-eventbridge.html
- aws\_cloudwatch\_event\_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
