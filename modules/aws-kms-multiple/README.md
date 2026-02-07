<!-- BEGIN_TF_DOCS -->
# **AWS KMS MULTIPLE Terraform Module**

## Overview

This module leverages the aws-kms module to create multiple custom KMS keys in AWS. For each key specified in `kms_to_create`, an alias is automatically generated in the format "custom/$kms\_to\_create". The module also grants permissions for access from other accounts if required, and enables replication to additional regions.

## Key Features

- **Multiple KMS Keys**: Creates one KMS key per value in `kms_to_create`, each with an appropriate policy.
- **Automatic Alias Generation**: Assigns an alias in the format "custom/$kms\_to\_create" for each key and its replicas.
- **KMS Replication**: Replicates each KMS key to all configured regions.
- **Cross-Account Access**: Optionally grants access permissions to other AWS accounts.

## Basic Usage

### Minimal Example (multiple KMS keys with automatic alias)

```hcl
module "kms" {
  source         = "github.com/prefapp/tfm/modules/aws-kms-multiple"
  kms_to_create  = [ { name = "rds" }, { name =  "s3" }, { name = "ec2" } ] # Each key will have alias "custom/<name>"
  aws_region     = "eu-west-1"
}
```

### With replication to other regions and cross-account access

```hcl
module "kms" {
  source              = "github.com/prefapp/tfm/modules/aws-kms-multiple"
  kms_to_create       = [ { name = "rds" }, { name = "s3", kms_alias_prefix = "myneworg/" }, { name = "ec2", via_service = ["ec2","lambda"] } ] # Aliases: custom/rds, myneworg/s3, custom/ec2
  aws_region          = "eu-west-1"
  aws_regions_replica = ["eu-central-1", "eu-west-2"] # Replicates each key to these regions
  aws_accounts_access = ["111111111111", "222222222222"] # Grants access to these AWS accounts
}
```

## File Structure

The module is organized with the following directory and file structure:

```
├── main.tf
├── variables.tf
├── _examples
│   ├── minimal
│   └── with_replication_account
├── README.md
└── docs
    └── header.md
```

- **main.tf**: Entry point that wires together all module components.

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_multiple-kms"></a> [multiple-kms](#module\_multiple-kms) | ../aws-kms | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_role_name"></a> [administrator\_role\_name](#input\_administrator\_role\_name) | Name of the IAM role to grant KMS administrator permissions. Set to null to disable granting permissions to this role. | `string` | `"Administrator"` | no |
| <a name="input_aws_accounts_access"></a> [aws\_accounts\_access](#input\_aws\_accounts\_access) | Enable access to KMS for additional AWS accounts | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to create KMS key | `string` | `"eu-west-1"` | no |
| <a name="input_aws_regions_replica"></a> [aws\_regions\_replica](#input\_aws\_regions\_replica) | List of AWS regions where KMS key replicas should be created | `list(string)` | `[]` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | The waiting period, specified in days, before the KMS key is deleted. Default is 30 days. | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key | `string` | `"Symmetric encryption KMS key"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Specifies whether key rotation is enabled. Default is true. | `bool` | `true` | no |
| <a name="input_kms_alias_prefix"></a> [kms\_alias\_prefix](#input\_kms\_alias\_prefix) | Prefix for the KMS key alias. The full alias will be constructed as '$prefix$kms\_name' for each KMS key created. | `string` | `"custom/"` | no |
| <a name="input_kms_to_create"></a> [kms\_to\_create](#input\_kms\_to\_create) | List of KMS keys to create. Each item must be an object, with at least the 'name' attribute.<br/>Example usage:<br/>  kms\_to\_create = [<br/>    { name = "s3" }, # Only name, uses default values for the rest<br/>    { name = "rds", alias = "custom-rds", kms\_alias\_prefix = "myorg/", via\_service = ["rds"] }<br/>  ] | <pre>list(object({<br/>    name                       = string<br/>    alias                      = optional(string)<br/>    kms_alias_prefix           = optional(string)<br/>    via_service                = optional(list(string))<br/>    user_roles_with_read       = optional(list(string))<br/>    user_roles_with_read_write = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_multiregion"></a> [multiregion](#input\_multiregion) | Specifies whether the KMS key is multi-region. Default is true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_user_roles_with_read"></a> [user\_roles\_with\_read](#input\_user\_roles\_with\_read) | List of IAM role names or users to grant read permissions to the KMS key. Set to null to disable granting permissions to any additional roles. | `list(string)` | `[]` | no |
| <a name="input_user_roles_with_read_write"></a> [user\_roles\_with\_read\_write](#input\_user\_roles\_with\_read\_write) | List of IAM role names to grant read/write permissions to the KMS key. Set to null to disable granting permissions to any additional roles. | `list(string)` | `[]` | no |

## Outputs

No outputs.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-kms-multiple/_examples):

- [Minimal](https://github.com/prefapp/tfm/tree/main/modules/aws-kms-multiple/_examples/minimal) – Minimal KMS MULTIPLE creation
- [KMS with replication](https://github.com/prefapp/tfm/tree/main/modules/aws-kms-multiple/_examples/with\_replication\_account) – KMS MULTIPLE creation with region replication

## Remote Resources
- Terraform: https://www.terraform.io/
- PREFAPP MODULE: https://github.com/prefapp/tfm/tree/main/modules/aws-kms
- Amazon KMS: [https://aws.amazon.com/kms/](https://aws.amazon.com/kms/)
- Terraform AWS Provider: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->