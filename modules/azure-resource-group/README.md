<!-- BEGIN_TF_DOCS -->
# Azure resource group Terraform module (`azure-resource-group`)

## Overview

This module creates a single **Azure resource group** (`azurerm_resource_group`). It is a thin wrapper around the provider resource with stable outputs and a `moved` block for state migration from the legacy resource address `azurerm_resource_group.resorce_group`.

## Key features

- **Single resource group**: `name`, `location`, and optional `tags`.
- **State migration**: `moved` from `azurerm_resource_group.resorce_group` to `azurerm_resource_group.this` (see `resource_groups.tf`).

## Prerequisites

- **azurerm** provider configured for your subscription.
- Valid **region** name for `location` (Azure REST naming, e.g. `westeurope`).

## Basic usage

```hcl
module "resource_group" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-resource-group?ref=<version>"

  name     = "my-app-rg"
  location = "westeurope"
  tags = {
    environment = "dev"
  }
}
```

## File structure

```
.
├── CHANGELOG.md
├── resource_groups.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   └── basic
├── README.md
└── .terraform-docs.yml
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region for the resource group (e.g. westeurope). Changing this forces a new resource group. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the resource group. Changing this forces a new resource group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to assign to the resource group. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource ID of the created resource group. |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | Azure region of the resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the created resource group. |
| <a name="output_resource_group_tags"></a> [resource\_group\_tags](#output\_resource\_group\_tags) | Tags applied to the resource group. |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-resource-group/_examples/basic) — Minimal module call with `name`, `location`, and tags.

## Remote resources

- **Terraform `azurerm_resource_group`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->