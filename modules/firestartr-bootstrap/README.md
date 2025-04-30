<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.terraform.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block.terraform.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_dynamodb_table.terraform.locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/dynamodb_table) | resource |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tfworkspaces_bucket_name | "Name of the S3 Bucket used for storing the Terraform state for the workspaces" | string | "" | Y |
| locks_dynamodb_table_name | "Name of the locks DynamoDB table" | string | "" | Y |
| tags | "Common tags for all resources" | string | "" | Y |


## Outputs

| Name | Description |
|------|-------------|
| tfworskpaces_bucket_arn | "tfworkspaces bucket's ARN" |
| locks_dynamodb_table_arn | "Locks' DynamoDB table's ARN" |
| locks_dynamodb_table_id | "Locks' DynamoDB table's ID" |

<!-- END_TF_DOCS -->

