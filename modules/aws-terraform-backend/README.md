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

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/dynamodb_table) | resource |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)| resource |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_cloudformation_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tfstate_bucket_name | "Name of the S3 Bucket used for storing the Terraform state for the workspaces" | string | -- | Y |
| tfstate_object_prefix | Prefix to the S3 bucket objects | string | -- | Y |
| locks_table_name | "Name of the locks DynamoDB table. Not needed if Terraform version is 1.11 or newer" | string | null | N |
| aws_region | AWS Region | string | -- | Y |
| tags | "Common tags for all resources" | map(string) | {} | N |
| tfstate_force_destroy | "Allow destroying the Terraform state bucket even if it contains objects" | boolean | false | N |
| tfstate_enable_versioning | "Enable versioning on the bucket" | boolean | true | N |
| aws_account_id | "AWS Account ID that will assume the role to access the S3 bucket and the dynamodb table" | string | - | Y |
| aws_account_role | "Role name that will assume the role to access the S3 bucket and the dynamodb table" | string | - | Y |
| generate_cloudformation_role_for_client_account | Decide whether to generate a cloudformation stack with a iam role to access the S3 bucket and the dynamodb table | boolean | true | N |
| upload_cloudformation_role | Decide whether to upload to S3 the cloudformation stack | boolean | true | N |
| s3_bucket_cloudformation_role | Name of the S3 bucket where the cloudformation template will be uploaded | string | "" | Only if "upload_cloudformation_role" is true |


## Outputs

| Name | Description |
|------|-------------|
| tfstate_bucket_arn | "ARN of the Terraform State S3 bucket" |
| tfstate_bucket_name | "Name of the Terraform State S3 bucket" |
| dynamodb_locks_table_arn | "ARN of the DynamoDB table (empty if not created)" |
| dynamodb_locks_table_name | "Name of the DynamoDB table (empty if not created)" |
| cloudformation_stack_id | "ID of the CloudFormation stack" |
| cloudformation_role_bucket_arn | "ARN of the S3 bucket where the CloudFormation stack will be saved" |
| cloudformation_role_bucket_name | "Name of the S3 bucket where the CloudFormation stack will be saved" |

<!-- END_TF_DOCS -->

