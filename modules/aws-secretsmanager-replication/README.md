<!-- BEGIN_TF_DOCS -->
# **AWS Secrets Manager Replication Terraform Module**

## Overview

This Terraform module provisions and manages a Lambda function for cross-account and cross-region replication of AWS Secrets Manager secrets. It automates the deployment of the Lambda, IAM roles, permissions, and (optionally) EventBridge rules to trigger secret replication on changes.

The module is designed for secure and automated secret replication, supporting flexible configuration of destination accounts and regions. It is suitable for organizations that need to synchronize secrets across multiple AWS environments for Disaster Recovery or multi-region scenarios.

## Key Features

- **Secrets Replication**: Automatically replicates secrets to one or more destination AWS accounts and/or regions.
- **Event-Driven**: Uses EventBridge to trigger replication when a secret is created or updated (optional).
- **Customizable Destinations**: Configure multiple destination accounts and regions, each with its own IAM role and KMS key.
- **IAM Role Management**: Creates all necessary IAM roles and policies for Lambda execution and cross-account access.
- **Environment Variables**: Supports custom environment variables for advanced configuration.
- **Tag Replication**: Optionally replicates tags from the source secret to the destination (controlled by the `enable_tag_replication` variable).

## Secret Replication Logic

This module deploys a Lambda function that listens for changes in AWS Secrets Manager via EventBridge (if enabled). When a secret is modified, the Lambda replicates it to the configured destinations, assuming roles as needed. The replication supports both secret value and tags (if enabled).

The Lambda determines:

- the **source secret** from the EventBridge event (automatic mode),
- from the `secret_id` parameter (manual mode),
- or from `list_secrets()` (full sync mode).

The **destination secret name is always the same as the source secret name**, simplifying configuration and IAM permissions.

### Destination Configuration Format

The destinations are configured via the `destinations_json` variable, which must be a JSON string with the following structure.
 **Each region now only requires the key `kms_key_arn`.**
 The module no longer uses `source_secret_arn`, `destination_secret_name`, or `destination_secret_arn`.

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
      }
    }
  }
}
```

You can specify as many destination accounts and regions as needed.
 Each region must specify the KMS key to use for encryption in that region.

### Tag Replication

By default, tags from the source secret are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions

**Important:**
 The Lambda IAM permissions for writing secrets in destination accounts are based on the **source secret name**, which is reused as the destination secret name.

The IAM policy must allow:

```
arn:aws:secretsmanager:<region>:<account>:secret:<secret_name>*
```

This wildcard allows the Lambda to manage all ARNs generated for a given secret name, regardless of AWS-generated suffixes.

The required schema for each region is now:

- `kms_key_arn`: ARN of the KMS key to use for encryption in the destination region.

All other fields previously required (`source_secret_arn`, `destination_secret_name`, `destination_secret_arn`) have been removed from the module and are no longer used.

## Architecture: Event-Driven Cross-Account Secret Replication

To replicate AWS Secrets Manager secrets between two accounts upon a change or rotation, the architecture relies on **AWS CloudTrail** as the intermediary, since Secrets Manager does not emit direct state-change events to EventBridge.

### Workflow Overview

1. **Source Action:** A change occurs in the source account via a Secrets Manager API call such as `CreateSecret` or `PutSecretValue`.
    Secret rotations are also handled because they invoke `PutSecretValue`.
2. **CloudTrail Capture:** This API activity is captured by a configured **CloudTrail Trail**.
3. **S3 Storage:** The Trail must be configured to deliver log files to a designated **S3 Bucket**.
4. **EventBridge Trigger:** An Amazon EventBridge rule filters for the pattern `AWS API Call via CloudTrail`, matching `CreateSecret` and `PutSecretValue` events.
5. **Lambda Execution:** The rule triggers a Lambda function, which assumes an IAM role to read the secret from the source and write/update it in the destination account.

### Required Resources & Links

- **CloudTrail:** Must be enabled to log management events.
  - Logging Secrets Manager events with CloudTrail [docs.aws.amazon.com](https://docs.aws.amazon.com/secretsmanager/latest/userguide/monitoring-cloudtrail.html)
- **S3 Bucket:** Required for storing CloudTrail logs.
  - Creating a trail for your AWS account [docs.aws.amazon.com](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html)
- **EventBridge:** Configured to listen to CloudTrail API calls.
  - Monitoring Secrets Manager with Amazon EventBridge [docs.aws.amazon.com](https://docs.aws.amazon.com/secretsmanager/latest/userguide/monitoring-eventbridge.html)

## Using Pre-Existing CloudTrail and S3 Buckets (Control Tower / Landing Zone)

In AWS Control Tower or Landing Zone environments, CloudTrail trails and S3 buckets for log storage are often provisioned centrally and shared across accounts. This module fully supports integration with these pre-existing resources.

**How to use:**

- Set `cloudtrail_name` to the name of the existing CloudTrail trail.
- Set `s3_bucket_name` to the name of the existing S3 bucket used by that trail.

The module will:

- Reference the existing CloudTrail and S3 bucket instead of creating new ones.
- Not attempt to modify or manage the lifecycle of these resources.
- Allow disabling S3 bucket policy management via `manage_s3_bucket_policy = false`.

**Important considerations:**

- The S3 bucket policy must allow CloudTrail to write logs.
- Both variables must be provided when using a pre-existing CloudTrail.
- This approach is recommended for centralized logging environments.

**Example:**

```hcl
module "secrets_replication" {
  # ... other variables ...
  cloudtrail_name         = "centralized-org-trail"
  s3_bucket_name          = "centralized-logs-bucket"
  manage_s3_bucket_policy = false
}
```

## EventBridge Rule Pattern (Secrets Manager)

The EventBridge rule should match Secrets Manager API calls via CloudTrail. Example pattern:

```json
{
  "source": ["aws.secretsmanager"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["PutSecretValue", "CreateSecret"]
  }
}
```

This ensures the rule triggers on all relevant Secrets Manager API calls recorded by CloudTrail.

## Required IAM Role in Destination Account

The destination account must have an IAM role that the replication Lambda can assume. This role should be specified in `destinations_json` as `role_arn` for each destination account.

### Minimum Policy for Secrets Manager Replication

```jsonc
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:CreateSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecret",
        "secretsmanager:DescribeSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource",
        "secretsmanager:UpdateSecretVersionStage",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "arn:aws:secretsmanager:<region>:<account>:secret:<secret_name>*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Resource": [
        "<kms_key_arn>"
      ]
    }
  ]
}
```

- Replace `<region>`, `<account>`, `<secret_name>`, and `<kms_key_arn>` with the actual values for your setup.
- The role must be assumable by the Lambda's source account. Example trust policy:

```jsonc
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::<source_account_id>:root" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

> You may need to further restrict or expand permissions depending on your organization's security requirements.

------

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.2 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_automatic_replication"></a> [lambda\_automatic\_replication](#module\_lambda\_automatic\_replication) | terraform-aws-modules/lambda/aws | ~> 7.0 |
| <a name="module_lambda_manual_replication"></a> [lambda\_manual\_replication](#module\_lambda\_manual\_replication) | terraform-aws-modules/lambda/aws | ~> 7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.secrets_management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_event_rule.secretsmanager_api_calls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_manual_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [random_integer.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_assume_roles"></a> [allowed\_assume\_roles](#input\_allowed\_assume\_roles) | List of IAM roles the Lambda can assume for cross-account replication | `list(string)` | n/a | yes |
| <a name="input_cloudtrail_arn"></a> [cloudtrail\_arn](#input\_cloudtrail\_arn) | (Optional) ARN of an existing CloudTrail. Required if using an existing trail. | `string` | `""` | no |
| <a name="input_cloudtrail_name"></a> [cloudtrail\_name](#input\_cloudtrail\_name) | (Optional) Name of an existing CloudTrail. Required if using an existing trail. | `string` | `""` | no |
| <a name="input_destinations_json"></a> [destinations\_json](#input\_destinations\_json) | JSON describing accounts, regions and KMS keys for replication | `string` | n/a | yes |
| <a name="input_enable_full_sync"></a> [enable\_full\_sync](#input\_enable\_full\_sync) | If true, the manual replication Lambda is granted secretsmanager:ListSecrets on all resources to support full-account sync. Set to false for strict least-privilege. | `bool` | `false` | no |
| <a name="input_enable_tag_replication"></a> [enable\_tag\_replication](#input\_enable\_tag\_replication) | Whether to replicate tags from the source secret (used by the code, not Terraform) | `bool` | `true` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Additional environment variables passed to the Lambda | `map(string)` | `{}` | no |
| <a name="input_eventbridge_enabled"></a> [eventbridge\_enabled](#input\_eventbridge\_enabled) | Whether to create the EventBridge rule that triggers the Lambda | `bool` | `true` | no |
| <a name="input_existing_bucket_policy_json"></a> [existing\_bucket\_policy\_json](#input\_existing\_bucket\_policy\_json) | Existing bucket policy JSON to merge with CloudTrail statements if using an existing bucket. Required when `manage_s3_bucket_policy` is true and `s3_bucket_name` is set. | `string` | `null` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Lambda memory in MB | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | `600` | no |
| <a name="input_manage_s3_bucket_policy"></a> [manage\_s3\_bucket\_policy](#input\_manage\_s3\_bucket\_policy) | If true, the module will apply the minimal S3 bucket policy required for CloudTrail to the chosen bucket. Set to false if the Landing Zone manages bucket policies. | `bool` | `true` | no |
| <a name="input_manual_replication_enabled"></a> [manual\_replication\_enabled](#input\_manual\_replication\_enabled) | Whether to deploy the manual secrets sync Lambda | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the Lambda and associated resources | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use for naming resources. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | (Optional) S3 bucket name where the CloudTrail log is stored. If provided, the module will reuse this bucket instead of creating one. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | ARN of the CloudTrail used (existing or created). |
| <a name="output_cloudtrail_name"></a> [cloudtrail\_name](#output\_cloudtrail\_name) | Name of the CloudTrail used (existing or created). |
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | ARN of the EventBridge rule (if created) |
| <a name="output_lambda_automatic_replication_arn"></a> [lambda\_automatic\_replication\_arn](#output\_lambda\_automatic\_replication\_arn) | ARN of the Lambda function |
| <a name="output_lambda_automatic_replication_role_arn"></a> [lambda\_automatic\_replication\_role\_arn](#output\_lambda\_automatic\_replication\_role\_arn) | IAM role ARN associated with the Lambda |
| <a name="output_lambda_manual_replication_arn"></a> [lambda\_manual\_replication\_arn](#output\_lambda\_manual\_replication\_arn) | ARN of the manual replication Lambda function (if created) |
| <a name="output_lambda_manual_replication_role_arn"></a> [lambda\_manual\_replication\_role\_arn](#output\_lambda\_manual\_replication\_role\_arn) | IAM role ARN for the manual replication Lambda (if created) |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | S3 bucket name used for CloudTrail logs (existing or created). |
| <a name="output_using_existing_cloudtrail"></a> [using\_existing\_cloudtrail](#output\_using\_existing\_cloudtrail) | True if an existing CloudTrail was provided. |
| <a name="output_using_existing_s3_bucket"></a> [using\_existing\_s3\_bucket](#output\_using\_existing\_s3\_bucket) | True if an existing S3 bucket name was provided. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-secretsmanager-replication/_examples):

- [Basic Replication](https://github.com/prefapp/tfm/tree/main/modules/aws-secretsmanager-replication/_examples/basic) – Replicate a secret to another AWS account or region
- [Existing CloudTrail & S3 Bucket](https://github.com/prefapp/tfm/tree/main/modules/aws-secretsmanager-replication/_examples/existing\_resources) – Use the module with pre-existing CloudTrail and S3 bucket (e.g., ControlTower environments)

## Remote resources
- Terraform: https://www.terraform.io/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- AWS Secrets Manager: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html
- aws\_secretsmanager\_secret: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
- AWS Lambda: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
- aws\_lambda\_function: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
- AWS EventBridge: https://docs.aws.amazon.com/eventbridge/latest/userguide/what-is-amazon-eventbridge.html
- aws\_cloudwatch\_event\_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule

## Support

For issues, questions, or contributions related to this module, please visit the [repository’s issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
