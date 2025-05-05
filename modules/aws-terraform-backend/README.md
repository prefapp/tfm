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
| bucket_name | "Name of the S3 Bucket used for storing the Terraform state for the workspaces" | string | "" | Y |
| dynamodb_table_name | "Name of the locks DynamoDB table. Not needed if Terraform version is 1.11 or newer" | string | null | N |
| tags | "Common tags for all resources" | string | "" | N |
| force_destroy | "Allow destroying the bucket even if it contains state" | boolean | false | N |
| enable_versioning | "Enable versioning on the bucket" | boolean | true | N |


## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_arn | "ARN of the S3 bucket" |
| dynamodb_table_arn | "ARN of the DynamoDB table, empty if not created" |

<!-- END_TF_DOCS -->

