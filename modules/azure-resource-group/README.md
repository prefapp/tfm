<!-- BEGIN_TF_DOCS -->
# Azure Resource Group Terraform Module

## Overview

This Terraform module allows you to create Azure Resource Groups with optional tags.

## Main features
- Create one or more resource groups in Azure.
- Support for custom tags for each resource group.
- Simple usage for both single and multiple groups.
- Realistic configuration example.

## Complete usage example

```terraform
module "github-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-resource-group?ref=<version>"
}
```

### HCL

```hcl
name     = "group_one"
location = "westEurope"
```

```hcl
name     = "group_two"
location = "westEurope"
tags     = {
  foo = "bar"
  bar = "foo"
}
```

## Notes
- You can define as many resource groups as needed, each with its own tags.
- Tags help organize and identify your resources.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── resource_groups.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to the Resource Group. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_resource_group_tags"></a> [resource\_group\_tags](#output\_resource\_group\_tags) | n/a |

## Resources and support

- [Official Azure Resource Group documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Terraform reference for azurerm\_resource\_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->