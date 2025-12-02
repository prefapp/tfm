<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_oidc_role"></a> [admin\_oidc\_role](#module\_admin\_oidc\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.60.0 |
| <a name="module_readwrite_oidc_role"></a> [readwrite\_oidc\_role](#module\_readwrite\_oidc\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.60.0 |

### Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.cloudformation_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_client_account_id"></a> [aws\_client\_account\_id](#input\_aws\_client\_account\_id) | AWS client account ID where the CloudFormation roles will be created | `string` | n/a | yes |
| <a name="input_cloudformation_s3_bucket"></a> [cloudformation\_s3\_bucket](#input\_cloudformation\_s3\_bucket) | S3 bucket where the CloudFormation template will be uploaded | `string` | `""` | no |
| <a name="input_cloudformation_s3_key"></a> [cloudformation\_s3\_key](#input\_cloudformation\_s3\_key) | S3 key for the CloudFormation template | `string` | `"cloudformation/terraform-backend-roles.yaml"` | no |
| <a name="input_generate_cloudformation_roles"></a> [generate\_cloudformation\_roles](#input\_generate\_cloudformation\_roles) | Generate CloudFormation template with IAM roles for external account access | `bool` | `true` | no |
| <a name="input_locks_table_name"></a> [locks\_table\_name](#input\_locks\_table\_name) | Name of the locks DynamoDB table | `string` | `null` | no |
| <a name="input_oidc_audiences"></a> [oidc\_audiences](#input\_oidc\_audiences) | List of allowed OIDC audiences (e.g., ['sts.amazonaws.com']) | `list(string)` | <pre>[<br/>  "sts.amazonaws.com"<br/>]</pre> | no |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | OIDC provider URL (e.g., token.actions.githubusercontent.com). If not provided, roles won't have OIDC trust | `string` | `""` | no |
| <a name="input_oidc_subjects"></a> [oidc\_subjects](#input\_oidc\_subjects) | Map of OIDC subjects for each role. Supports both exact matches and wildcards.<br/>Example:<br/>{<br/>  admin = {<br/>    exact    = ["repo:myorg/myrepo:ref:refs/heads/main"]<br/>    wildcard = ["repo:myorg/myrepo:*"]<br/>  }<br/>  readwrite = {<br/>    exact    = ["repo:myorg/myrepo:ref:refs/heads/develop"]<br/>    wildcard = ["repo:myorg/*:pull\_request"]<br/>  }<br/>} | <pre>map(object({<br/>    exact    = optional(list(string), [])<br/>    wildcard = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Configuration for IAM roles in the backend account.<br/>Each role can assume a corresponding role in the client account via CloudFormation.<br/><br/>Structure:<br/>- admin: Full admin access role (required)<br/>  - name: Role name in backend account<br/>  - external\_role\_name: Role name to create in client account via CloudFormation<br/>  - aws\_account\_id: Backend account ID (defaults to current account)<br/>- readwrite: Read-write S3 access role (optional)<br/>  - name: Role name in backend account<br/>  - external\_role\_name: Role name to create in client account via CloudFormation<br/>  - aws\_account\_id: Backend account ID (defaults to current account) | <pre>object({<br/>    admin = object({<br/>      name               = string<br/>      external_role_name = string<br/>      aws_account_id     = optional(string)<br/>    })<br/>    readwrite = optional(object({<br/>      name               = string<br/>      external_role_name = string<br/>      aws_account_id     = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | Name of the S3 Bucket used for storing the Terraform state for the workspaces | `string` | n/a | yes |
| <a name="input_tfstate_enable_versioning"></a> [tfstate\_enable\_versioning](#input\_tfstate\_enable\_versioning) | Enable versioning on the bucket | `bool` | `true` | no |
| <a name="input_tfstate_force_destroy"></a> [tfstate\_force\_destroy](#input\_tfstate\_force\_destroy) | Allow destroying the Terraform state bucket even if it contains objects | `bool` | `false` | no |
| <a name="input_tfstate_object_prefix"></a> [tfstate\_object\_prefix](#input\_tfstate\_object\_prefix) | Prefix to the S3 bucket objects | `string` | n/a | yes |
| <a name="input_upload_cloudformation_template"></a> [upload\_cloudformation\_template](#input\_upload\_cloudformation\_template) | Upload the CloudFormation template to S3 | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_role_arn"></a> [admin\_role\_arn](#output\_admin\_role\_arn) | ARN of the admin role in the backend account |
| <a name="output_admin_role_name"></a> [admin\_role\_name](#output\_admin\_role\_name) | Name of the admin role in the backend account |
| <a name="output_cloudformation_template_content"></a> [cloudformation\_template\_content](#output\_cloudformation\_template\_content) | CloudFormation template YAML content (only if not uploaded to S3) |
| <a name="output_cloudformation_template_s3_https_url"></a> [cloudformation\_template\_s3\_https\_url](#output\_cloudformation\_template\_s3\_https\_url) | HTTPS URL of the uploaded CloudFormation template |
| <a name="output_cloudformation_template_s3_url"></a> [cloudformation\_template\_s3\_url](#output\_cloudformation\_template\_s3\_url) | S3 URL of the uploaded CloudFormation template |
| <a name="output_dynamodb_locks_table_arn"></a> [dynamodb\_locks\_table\_arn](#output\_dynamodb\_locks\_table\_arn) | ARN of the DynamoDB locks table (empty if not created) |
| <a name="output_dynamodb_locks_table_name"></a> [dynamodb\_locks\_table\_name](#output\_dynamodb\_locks\_table\_name) | Name of the DynamoDB locks table (empty if not created) |
| <a name="output_external_admin_role_name"></a> [external\_admin\_role\_name](#output\_external\_admin\_role\_name) | Name of the admin role to be created in the client account via CloudFormation |
| <a name="output_external_readwrite_role_name"></a> [external\_readwrite\_role\_name](#output\_external\_readwrite\_role\_name) | Name of the readwrite role to be created in the client account via CloudFormation |
| <a name="output_readwrite_role_arn"></a> [readwrite\_role\_arn](#output\_readwrite\_role\_arn) | ARN of the readwrite role in the backend account (null if not created) |
| <a name="output_readwrite_role_name"></a> [readwrite\_role\_name](#output\_readwrite\_role\_name) | Name of the readwrite role in the backend account (empty if not created) |
| <a name="output_tfstate_bucket_arn"></a> [tfstate\_bucket\_arn](#output\_tfstate\_bucket\_arn) | ARN of the Terraform State S3 bucket |
| <a name="output_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#output\_tfstate\_bucket\_name) | Name of the Terraform State S3 bucket |
<!-- END_TF_DOCS -->

