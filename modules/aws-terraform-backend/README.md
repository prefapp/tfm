<!-- BEGIN_TF_DOCS -->
# **AWS Terraform Backend Module**

## Overview

This module provisions the AWS infrastructure typically required by a Terraform backend: an S3 bucket for state files, optional DynamoDB locking, and IAM policies/roles to access backend resources.

It also supports rendering an optional CloudFormation template and uploading it to S3 so another account can assume an administrative role for backend operations when needed.

The module is intended for shared platform/backend setups where consistency, least-privilege access, and safe state handling are important.

## Key Features

- **S3 state bucket**: Creates an S3 bucket with versioning, encryption, and public access blocking.
- **Optional DynamoDB locking**: Creates a lock table when `locks_table_name` is provided.
- **IAM backend access role and policies**: Manages backend IAM role plus attachable policy for extra roles.
- **Optional CloudFormation role template upload**: Generates and uploads role template to S3 when enabled.

## Basic Usage

### Backend with DynamoDB locking

```hcl
module "terraform_backend" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-terraform-backend"

  tfstate_bucket_name   = "my-terraform-state-bucket"
  tfstate_object_prefix = "envs/prod/terraform.tfstate"
  locks_table_name      = "my-terraform-locks"

  aws_account_id                              = "123456789012"
  cloudformation_admin_role_for_client_account = "tf-backend-admin"
}
```

### Backend without DynamoDB locking (Terraform >= 1.11)

```hcl
module "terraform_backend" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-terraform-backend"

  tfstate_bucket_name   = "my-terraform-state-bucket"
  tfstate_object_prefix = "envs/dev/terraform.tfstate"
  locks_table_name      = null

  aws_account_id                              = "123456789012"
  cloudformation_admin_role_for_client_account = "tf-backend-admin"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.full](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.limited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.extra_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.tfstate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID that will assume the role to access the S3 bucket and the dynamodb table | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `null` | no |
| <a name="input_backend_extra_roles"></a> [backend\_extra\_roles](#input\_backend\_extra\_roles) | Additional roles to add to the Terraform backend access role | `list(string)` | `[]` | no |
| <a name="input_cloudformation_admin_role_for_client_account"></a> [cloudformation\_admin\_role\_for\_client\_account](#input\_cloudformation\_admin\_role\_for\_client\_account) | Role name that will assume the role to access the S3 bucket and the dynamodb table | `string` | n/a | yes |
| <a name="input_create_github_iam"></a> [create\_github\_iam](#input\_create\_github\_iam) | Create IAM resources for GitHub | `bool` | `false` | no |
| <a name="input_generate_cloudformation_role_for_client_account"></a> [generate\_cloudformation\_role\_for\_client\_account](#input\_generate\_cloudformation\_role\_for\_client\_account) | Decide whether to generate a cloudformation stack with a iam role to access the account with administrative privileges | `bool` | `true` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | Name of the GitHub repository to access the backend | `string` | `""` | no |
| <a name="input_locks_table_name"></a> [locks\_table\_name](#input\_locks\_table\_name) | Name of the locks DynamoDB table | `string` | `null` | no |
| <a name="input_s3_bucket_cloudformation_role"></a> [s3\_bucket\_cloudformation\_role](#input\_s3\_bucket\_cloudformation\_role) | Name of the S3 bucket where the cloudformation template will be uploaded | `string` | `""` | no |
| <a name="input_s3_bucket_cloudformation_role_key"></a> [s3\_bucket\_cloudformation\_role\_key](#input\_s3\_bucket\_cloudformation\_role\_key) | Key to use when uploading the template to S3 | `string` | `"cloudformation/rendered-template.yaml"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_tfbackend_access_role_name"></a> [tfbackend\_access\_role\_name](#input\_tfbackend\_access\_role\_name) | Terraform backend access role | `string` | `"terraform-backend-access-role"` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | Name of the S3 Bucket used for storing the Terraform state for the workspaces | `string` | n/a | yes |
| <a name="input_tfstate_enable_versioning"></a> [tfstate\_enable\_versioning](#input\_tfstate\_enable\_versioning) | Enable versioning on the bucket | `bool` | `true` | no |
| <a name="input_tfstate_force_destroy"></a> [tfstate\_force\_destroy](#input\_tfstate\_force\_destroy) | Allow destroying the Terraform state bucket even if it contains objects | `bool` | `false` | no |
| <a name="input_tfstate_object_prefix"></a> [tfstate\_object\_prefix](#input\_tfstate\_object\_prefix) | Prefix to the S3 bucket objects | `string` | n/a | yes |
| <a name="input_upload_cloudformation_role"></a> [upload\_cloudformation\_role](#input\_upload\_cloudformation\_role) | Decide whether to upload to S3 the cloudformation stack | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_locks_table_arn"></a> [dynamodb\_locks\_table\_arn](#output\_dynamodb\_locks\_table\_arn) | ARN of the DynamoDB table (empty if not created) |
| <a name="output_dynamodb_locks_table_name"></a> [dynamodb\_locks\_table\_name](#output\_dynamodb\_locks\_table\_name) | Name of the DynamoDB table (empty if not created) |
| <a name="output_rendered_template_content"></a> [rendered\_template\_content](#output\_rendered\_template\_content) | Cloudformation stack with a iam role to access the S3 bucket and the dynamodb table |
| <a name="output_s3_template_url"></a> [s3\_template\_url](#output\_s3\_template\_url) | S3 URL of the uploaded template (only if 'upload\_cloudformation\_role' is true) |
| <a name="output_tfstate_bucket_arn"></a> [tfstate\_bucket\_arn](#output\_tfstate\_bucket\_arn) | ARN of the Terraform State S3 bucket |
| <a name="output_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#output\_tfstate\_bucket\_name) | Name of the Terraform State S3 bucket |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-terraform-backend/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-terraform-backend/_examples/basic) - Terraform backend with S3 bucket and DynamoDB lock table.
- [Without Lock Table](https://github.com/prefapp/tfm/tree/main/modules/aws-terraform-backend/_examples/without-lock-table) - Terraform backend with S3 bucket only.

## Resources

- [Terraform S3 Backend](https://developer.hashicorp.com/terraform/language/backend/s3)
- [Amazon S3](https://aws.amazon.com/s3/)
- [Amazon DynamoDB](https://aws.amazon.com/dynamodb/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository's issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->

