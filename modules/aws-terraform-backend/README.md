<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.97.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.full](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.limited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.that](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.that](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.limited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.that](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.tfstate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aux_role_name"></a> [aux\_role\_name](#input\_aux\_role\_name) | Terraform backend access role (auxiliary) | `string` | `"terraform-backend-aux-access-role"` | no |
| <a name="input_aws_client_account_id"></a> [aws\_client\_account\_id](#input\_aws\_client\_account\_id) | AWS Account ID that will assume the role that allows access to the S3 bucket and the dynamodb table | `string` | n/a | yes |
| <a name="input_backend_extra_roles"></a> [backend\_extra\_roles](#input\_backend\_extra\_roles) | Additional roles to add to the Terraform backend access role | `list(string)` | `[]` | no |
| <a name="input_create_aux_role"></a> [create\_aux\_role](#input\_create\_aux\_role) | Decide whether to generate a specific auxiliary role for the client account | `bool` | `false` | no |
| <a name="input_create_oidc_trust_relationship"></a> [create\_github\_iam](#input\_create\_github\_iam) | Create IAM resources for GitHub | `bool` | `false` | no |
| <a name="input_external_aux_role"></a> [external\_aux\_role](#input\_external\_aux\_role) | Role name that will assume the role to access the S3 bucket and the dynamodb table with read-only access | `string` | `""` | no |
| <a name="input_external_main_role"></a> [external\_main\_role](#input\_external\_main\_role) | Role name that will assume the role to access the S3 bucket and the dynamodb table with admin access | `string` | n/a | yes |
| <a name="input_generate_cloudformation_role_for_external_account"></a> [generate\_cloudformation\_role\_for\_client\_account](#input\_generate\_cloudformation\_role\_for\_client\_account) | Decide whether to generate a cloudformation stack with a iam role to access the account with administrative privileges | `bool` | `true` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | Name of the GitHub repository to access the backend | `string` | `""` | no |
| <a name="input_locks_table_name"></a> [locks\_table\_name](#input\_locks\_table\_name) | Name of the locks DynamoDB table | `string` | `null` | no |
| <a name="input_main_role_name"></a> [main\_role\_name](#input\_main\_role\_name) | Terraform backend access role name (main) | `string` | `"terraform-backend-access-role"` | no |
| <a name="input_s3_bucket_cloudformation_role"></a> [s3\_bucket\_cloudformation\_role](#input\_s3\_bucket\_cloudformation\_role) | Name of the S3 bucket where the cloudformation template will be uploaded | `string` | `""` | no |
| <a name="input_s3_bucket_cloudformation_role_key"></a> [s3\_bucket\_cloudformation\_role\_key](#input\_s3\_bucket\_cloudformation\_role\_key) | Key to use when uploading the template to S3 | `string` | `"cloudformation/rendered-template.yaml"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | Name of the S3 Bucket used for storing the Terraform state for the workspaces | `string` | n/a | yes |
| <a name="input_tfstate_enable_versioning"></a> [tfstate\_enable\_versioning](#input\_tfstate\_enable\_versioning) | Enable versioning on the bucket | `bool` | `true` | no |
| <a name="input_tfstate_force_destroy"></a> [tfstate\_force\_destroy](#input\_tfstate\_force\_destroy) | Allow destroying the Terraform state bucket even if it contains objects | `bool` | `false` | no |
| <a name="input_tfstate_object_prefix"></a> [tfstate\_object\_prefix](#input\_tfstate\_object\_prefix) | Prefix to the S3 bucket objects | `string` | n/a | yes |
| <a name="input_upload_cloudformation_role"></a> [upload\_cloudformation\_role](#input\_upload\_cloudformation\_role) | Decide whether to upload to S3 the cloudformation stack | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_locks_table_arn"></a> [dynamodb\_locks\_table\_arn](#output\_dynamodb\_locks\_table\_arn) | ARN of the DynamoDB table (empty if not created) |
| <a name="output_dynamodb_locks_table_name"></a> [dynamodb\_locks\_table\_name](#output\_dynamodb\_locks\_table\_name) | Name of the DynamoDB table (empty if not created) |
| <a name="output_rendered_template_content"></a> [rendered\_template\_content](#output\_rendered\_template\_content) | Cloudformation stack with a iam role to access the S3 bucket and the dynamodb table |
| <a name="output_s3_template_url"></a> [s3\_template\_url](#output\_s3\_template\_url) | S3 URL of the uploaded template (only if 'upload\_cloudformation\_role' is true) |
| <a name="output_tfstate_bucket_arn"></a> [tfstate\_bucket\_arn](#output\_tfstate\_bucket\_arn) | ARN of the Terraform State S3 bucket |
| <a name="output_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#output\_tfstate\_bucket\_name) | Name of the Terraform State S3 bucket |
<!-- END_TF_DOCS -->

