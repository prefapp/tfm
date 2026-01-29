<!-- BEGIN_TF_DOCS -->
# **AWS KMS Terraform Module**

## Overview

This module creates custom KMS keys in AWS, grants permissions for access from other accounts if necessary, and enables replication to other regions.

## Key Features

- **KMS**: Creates a KMS key with an appropriate policy.
- **KMS Replication**: Creates replication in the configured regions.
- **KMS Alias**: Creates an alias for the KMS key and for each replica in other regions.

## Basic Usage

### Minimal Example (KMS without alias)

```hcl
module "kms" {
  source = "github.com/prefapp/tfm/modules/aws-kms"
  aws_region = "eu-west-1"
}
```

### With alias and replication to other regions

```hcl
module "kms" {
  source = "github.com/prefapp/tfm/modules/aws-kms"
  aws_region = "eu-west-1"
  alias = "rds"
  aws_regions_replica = ["eu-central-1", "eu-west-2"]
}
```

### With alias, replication to other regions, and access from other AWS accounts

```hcl
module "kms" {
  source = "github.com/prefapp/tfm/modules/aws-kms"
  aws_region = "eu-west-1"
  alias = "rds"
  aws_regions_replica = ["eu-central-1", "eu-west-2"]
  aws_accounts_access = ["111111111111", "222222222222"]
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── data.tf
├── main.tf
├── variables.tf
├── _examples
│   ├── minimal
│   ├── with_alias_replication
│   └── with_alias_replication_account
├── README.md
└── docs
    └── header.md
```

- **main.tf**: Entry point that wires together all module components.
- **data.tf**: Policy document for KMS key and replication.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.this_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_key.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_default_statement](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.role_used_by_sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_role_name"></a> [administrator\_role\_name](#input\_administrator\_role\_name) | Name of the IAM role to grant KMS administrator permissions. Set to null to disable granting permissions to this role. | `string` | `"Administrator"` | no |
| <a name="input_alias"></a> [alias](#input\_alias) | The alias that will use the KMS key | `string` | `null` | no |
| <a name="input_aws_accounts_access"></a> [aws\_accounts\_access](#input\_aws\_accounts\_access) | Enable access to kms for additional AWS accounts | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to create kms key | `string` | `"eu-west-1"` | no |
| <a name="input_aws_regions_replica"></a> [aws\_regions\_replica](#input\_aws\_regions\_replica) | List of AWS regions where KMS key replicas should be created | `list(string)` | `[]` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | The waiting period, specified in days, before the KMS key is deleted. Default is 30 days. | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key | `string` | `"Symmetric encryption KMS key"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Specifies whether key rotation is enabled. Default is true. | `bool` | `true` | no |
| <a name="input_multiregion"></a> [multiregion](#input\_multiregion) | Specifies whether the KMS key is multi-region. Default is true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | The Amazon Resource Name (ARN) of the KMS key alias (null if not created) |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | The name of the KMS key alias (null if not created) |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The Amazon Resource Name (ARN) of the KMS key |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique identifier for the KMS key |
| <a name="output_replica_alias_arns"></a> [replica\_alias\_arns](#output\_replica\_alias\_arns) | Map of replica region to KMS replica alias ARNs (empty if alias not created) |
| <a name="output_replica_key_arns"></a> [replica\_key\_arns](#output\_replica\_key\_arns) | Map of replica region to KMS replica key ARNs |
| <a name="output_replica_key_ids"></a> [replica\_key\_ids](#output\_replica\_key\_ids) | Map of replica region to KMS replica key IDs |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-kms/_examples):

- [Minimal](https://github.com/prefapp/tfm/tree/main/modules/aws-kms/_examples/minimal) – Minimal KMS creation
- [KMS with alias and replication](https://github.com/prefapp/tfm/tree/main/modules/aws-kms/_examples/with\_alias\_replication) – KMS creation with alias and region replication
- [KMS with alias, replication, and extra account access](https://github.com/prefapp/tfm/tree/main/modules/aws-kms/_examples/with\_alias\_replication\_account) – KMS creation with alias, region replication, and extra account access

## Remote Resources
- Terraform: https://www.terraform.io/
- Amazon KMS: [https://aws.amazon.com/kms/](https://aws.amazon.com/kms/)
- Terraform AWS Provider: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->