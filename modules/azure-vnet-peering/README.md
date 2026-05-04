<!-- BEGIN_TF_DOCS -->
# Azure Virtual Network peering Terraform module

## Overview

This module creates **two** `azurerm_virtual_network_peering` resources so that two existing virtual networks peer with each other (origin → destination and destination → origin). It looks up both VNets with data sources and does **not** create resource groups or virtual networks; those must already exist in Azure.

Typical use: connect a hub and spoke, join application VNets, or complete full mesh steps when each side is managed separately.

## Key features

- **Bidirectional peering**: One apply creates both peerings with independent names per direction.
- **Data-only inputs**: Uses `azurerm_virtual_network` data sources for origin and destination; you supply VNet names and resource group names.
- **Minimal surface**: No optional gateway or forwarded-traffic flags in this module; defaults follow the provider for unspecified arguments.

## Prerequisites

- Origin and destination **resource groups** exist.
- Origin and destination **virtual networks** exist.
- AzureRM provider configured in the root module (authentication, subscription, `features {}` as required).

## Basic usage

Set all six string variables: origin VNet + RG + peering name, and destination VNet + RG + peering name. Peering names must be unique within each VNet.

### Example

```hcl
module "azure_vnet_peering" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-peering?ref=<version>"

  origin_virtual_network_name      = "hub-vnet"
  origin_resource_group_name       = "hub-rg"
  origin_name_peering              = "hub-to-spoke"

  destination_virtual_network_name = "spoke-vnet"
  destination_resource_group_name  = "spoke-rg"
  destination_name_peering         = "spoke-to-hub"
}
```

## File structure

```
.
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── peering.tf
├── variables.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   └── basic
├── README.md
└── .terraform-docs.yml
```

- **`data.tf`**: Data sources for origin and destination virtual networks.
- **`peering.tf`**: Both `azurerm_virtual_network_peering` resources.
- **`main.tf`**: Terraform block and `azurerm` provider version constraint.
- **`variables.tf`**: Input variables for VNets, resource groups, and peering names.
- **`outputs.tf`**: Echoes the input values used (useful for wiring to other modules or state inspection).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.85.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.destination-to-origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.origin-to-destination](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network.id_virtual_network_destination](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [azurerm_virtual_network.id_virtual_network_origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_name_peering"></a> [destination\_name\_peering](#input\_destination\_name\_peering) | (Required) Name of the destination→origin virtual network peering resource on the destination VNet. Changing this forces a new peering to be created. | `string` | n/a | yes |
| <a name="input_destination_resource_group_name"></a> [destination\_resource\_group\_name](#input\_destination\_resource\_group\_name) | (Required) Resource group that contains the existing destination virtual network (used for the data source lookup and as `resource_group_name` on the destination→origin peering). | `string` | n/a | yes |
| <a name="input_destination_virtual_network_name"></a> [destination\_virtual\_network\_name](#input\_destination\_virtual\_network\_name) | (Required) Name of the existing destination virtual network to look up. This module does not create the VNet. | `string` | n/a | yes |
| <a name="input_origin_name_peering"></a> [origin\_name\_peering](#input\_origin\_name\_peering) | (Required) Name of the origin→destination virtual network peering resource on the origin VNet. Changing this forces a new peering to be created. | `string` | n/a | yes |
| <a name="input_origin_resource_group_name"></a> [origin\_resource\_group\_name](#input\_origin\_resource\_group\_name) | (Required) Resource group that contains the existing origin virtual network (used for the data source lookup and as `resource_group_name` on the origin→destination peering). | `string` | n/a | yes |
| <a name="input_origin_virtual_network_name"></a> [origin\_virtual\_network\_name](#input\_origin\_virtual\_network\_name) | (Required) Name of the existing origin virtual network to look up. This module does not create the VNet. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_name_peering_output"></a> [destination\_name\_peering\_output](#output\_destination\_name\_peering\_output) | Peering name on the destination virtual network (destination → origin). |
| <a name="output_destination_resource_group_name_output"></a> [destination\_resource\_group\_name\_output](#output\_destination\_resource\_group\_name\_output) | Resource group name of the destination virtual network. |
| <a name="output_destination_virtual_network_name_output"></a> [destination\_virtual\_network\_name\_output](#output\_destination\_virtual\_network\_name\_output) | Name of the destination virtual network. |
| <a name="output_origin_name_peering_output"></a> [origin\_name\_peering\_output](#output\_origin\_name\_peering\_output) | Peering name on the origin virtual network (origin → destination). |
| <a name="output_origin_resource_group_name_output"></a> [origin\_resource\_group\_name\_output](#output\_origin\_resource\_group\_name\_output) | Resource group name of the origin virtual network. |
| <a name="output_origin_virtual_network_name_output"></a> [origin\_virtual\_network\_name\_output](#output\_origin\_virtual\_network\_name\_output) | Name of the origin virtual network. |

## Examples

For a runnable skeleton, see the [basic example](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-peering/_examples/basic).

## Remote resources

- **Azure Virtual Network peering**: [https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview)
- **Terraform `azurerm_virtual_network_peering`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->