<!-- BEGIN_TF_DOCS -->


# **AWS Secrets Manager Copy Terraform Module**

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

### Destination Configuration Format

The destinations are configured via the `destinations_json` variable, which must be a JSON string with the following structure:

```json
{
	"DEST_ACCOUNT_ID": {
		"role_arn": "arn:aws:iam::DEST_ACCOUNT_ID:role/ReplicationRole",
		"regions": {
			"us-east-1": {
				"kms_key_id": "arn:aws:kms:us-east-1:DEST_ACCOUNT_ID:key/xxxx"
			},
			"eu-west-1": {
				"kms_key_id": "arn:aws:kms:eu-west-1:DEST_ACCOUNT_ID:key/yyyy"
			}
		}
	}
}
```

You can specify as many destination accounts and regions as needed. Each region must specify the KMS key to use for secret encryption.

### Tag Replication

By default, tags from the source secret are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions

Ensure that the destination roles have the necessary permissions to create and update secrets in the target accounts/regions. The source Lambda role must also have permission to assume these roles and read the source secrets.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | terraform-aws-modules/lambda/aws | ~> 7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.secret_change](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_permission.allow_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_assume_roles"></a> [allowed\_assume\_roles](#input\_allowed\_assume\_roles) | List of IAM roles the Lambda can assume for cross-account replication | `list(string)` | n/a | yes |
| <a name="input_destinations_json"></a> [destinations\_json](#input\_destinations\_json) | JSON describing accounts, regions and KMS keys for replication | `string` | n/a | yes |
| <a name="input_enable_tag_replication"></a> [enable\_tag\_replication](#input\_enable\_tag\_replication) | Whether to replicate tags from the source secret (used by the code, not Terraform) | `bool` | `true` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Additional environment variables passed to the Lambda | `map(string)` | `{}` | no |
| <a name="input_eventbridge_enabled"></a> [eventbridge\_enabled](#input\_eventbridge\_enabled) | Whether to create the EventBridge rule that triggers the Lambda | `bool` | `true` | no |
| <a name="input_lambda_memory"></a> [lambda\_memory](#input\_lambda\_memory) | Lambda memory in MB | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | `10` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the Lambda and associated resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | ARN of the EventBridge rule (if created) |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN of the Lambda function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | IAM role ARN associated with the Lambda |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-secretsmanager-copy/_examples):

- [Basic Replication](https://github.com/prefapp/tfm/tree/main/modules/aws-secretsmanager-copy/_examples/basic) – Replicate a secret to another AWS account or region

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