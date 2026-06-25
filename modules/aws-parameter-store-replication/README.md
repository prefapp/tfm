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

This module deploys a Lambda function that listens for changes in AWS Systems Manager Parameter Store via EventBridge (if enabled). When a parameter is modified, the Lambda replicates it to the configured destinations, assuming roles as needed. The replication supports both parameter value and tags (if enabled).

The Lambda determines:

- the **source parameter** from the EventBridge event (automatic mode),
- from the `parameter_name` parameter (manual mode),
- or from `describe_parameters()` (full sync mode).

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

By default, tags from the source parameter are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions

**Important:**
 The **destination replication role** (assumed by the Lambda in each destination account) must allow managing the destination parameter name produced by this module.

The IAM policy in the destination account must allow:

```
arn:aws:ssm:<region>:<account>:parameter<destination_parameter_name>
```

Where `<destination_parameter_name>` is determined by the module's naming logic:
- If `add_region_prefix_to_name = false` (default): matches the source parameter name.
- If `add_region_prefix_to_name = true`: region-prefixed, e.g., `/eu-west-1/my/parameter` (path-style) or `eu-west-1-myparameter` (simple name).

This allows the replication role to manage the destination parameter across all its versions.

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

  allowed_assume_roles = [
    "arn:aws:iam::123456789012:role/ParameterReplicationRole"
  ]

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

  allowed_assume_roles = [
    "arn:aws:iam::111111111111:role/ParameterReplicationRole",
    "arn:aws:iam::222222222222:role/ParameterReplicationRole"
  ]

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.52.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_automatic_replication"></a> [lambda\_automatic\_replication](#module\_lambda\_automatic\_replication) | terraform-aws-modules/lambda/aws | ~> 7.0 |
| <a name="module_lambda_manual_replication"></a> [lambda\_manual\_replication](#module\_lambda\_manual\_replication) | terraform-aws-modules/lambda/aws | ~> 7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.parameter_store_api_calls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.lambda_automatic_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_manual_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_manual_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_manual_ssm_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_manual_ssm_write_destinations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_ssm_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_ssm_write_destinations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_automatic_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_manual_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_region_prefix_to_name"></a> [add\_region\_prefix\_to\_name](#input\_add\_region\_prefix\_to\_name) | If true, the destination parameter name is region-prefixed.<br/>For simple names: "myparameter" -> "us-east-1-myparameter".<br/>For path-style names: "/my/parameter" -> "/us-east-1/my/parameter".<br/>If false, the original name is used. Default: false.<br/>This helps avoid collisions if you replicate parameters with the same name from multiple regions. | `bool` | `false` | no |
| <a name="input_allowed_assume_roles"></a> [allowed\_assume\_roles](#input\_allowed\_assume\_roles) | List of IAM roles the Lambda can assume for cross-account replication | `list(string)` | `[]` | no |
| <a name="input_destinations_json"></a> [destinations\_json](#input\_destinations\_json) | JSON describing accounts, regions and KMS keys for replication | `string` | n/a | yes |
| <a name="input_enable_full_sync"></a> [enable\_full\_sync](#input\_enable\_full\_sync) | If true, the manual replication Lambda is granted ssm:DescribeParameters on all resources to support full-account sync. Set to false for strict least-privilege. | `bool` | `false` | no |
| <a name="input_enable_tag_replication"></a> [enable\_tag\_replication](#input\_enable\_tag\_replication) | Whether to replicate tags from the source parameter (used by the code, not Terraform) | `bool` | `true` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Additional environment variables passed to the Lambda | `map(string)` | `{}` | no |
| <a name="input_eventbridge_enabled"></a> [eventbridge\_enabled](#input\_eventbridge\_enabled) | Whether to create the EventBridge rule that triggers the Lambda | `bool` | `false` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Lambda memory in MB | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | `600` | no |
| <a name="input_manual_replication_enabled"></a> [manual\_replication\_enabled](#input\_manual\_replication\_enabled) | Whether to deploy the manual parameter sync Lambda | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the Lambda and associated resources | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use for naming resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | ARN of the EventBridge rule (if created) |
| <a name="output_lambda_automatic_replication_arn"></a> [lambda\_automatic\_replication\_arn](#output\_lambda\_automatic\_replication\_arn) | ARN of the Lambda function |
| <a name="output_lambda_automatic_replication_role_arn"></a> [lambda\_automatic\_replication\_role\_arn](#output\_lambda\_automatic\_replication\_role\_arn) | IAM role ARN associated with the Lambda |
| <a name="output_lambda_manual_replication_arn"></a> [lambda\_manual\_replication\_arn](#output\_lambda\_manual\_replication\_arn) | ARN of the manual replication Lambda function (if created) |
| <a name="output_lambda_manual_replication_role_arn"></a> [lambda\_manual\_replication\_role\_arn](#output\_lambda\_manual\_replication\_role\_arn) | IAM role ARN for the manual replication Lambda (if created) |

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
