<!-- BEGIN_TF_DOCS -->
# Azure Virtual Network Peering Module

This Terraform module creates a virtual network peering between two Azure virtual networks.

## Features
- Creates peering from origin to destination VNet
- Creates peering from destination to origin VNet
- Supports custom names for each peering

## Real usage example

### Set a module

```terraform
module "azure-vnet-peering" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-peering?ref=<version>"
}
```

###############
# VNET ORIGIN #
###############

  origin\_virtual\_network\_name      = "origen-vnet"
  origin\_resource\_group\_name       = "test-peering"
  origin\_name\_peering              = "origen-vnet-to-destino-vnet"

####################
# VNET DESTINATION #
####################

  destination\_virtual\_network\_name = "destino-vnet"
  destination\_resource\_group\_name  = "test-peering"
  destination\_name\_peering         = "destino-vnet-to-origen-vnet"
}

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.85.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.85.0 |

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
| <a name="input_destination_name_peering"></a> [destination\_name\_peering](#input\_destination\_name\_peering) | (Required) The name of the destination to origin peering. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_destination_resource_group_name"></a> [destination\_resource\_group\_name](#input\_destination\_resource\_group\_name) | (Required) The name of the resource group in which to create the destination virtual network. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_destination_virtual_network_name"></a> [destination\_virtual\_network\_name](#input\_destination\_virtual\_network\_name) | (Required) The name of the destination virtual network. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_origin_name_peering"></a> [origin\_name\_peering](#input\_origin\_name\_peering) | (Required) The name of the origin to destination peering. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_origin_resource_group_name"></a> [origin\_resource\_group\_name](#input\_origin\_resource\_group\_name) | (Required) The name of the resource group in which to create the origin virtual network. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_origin_virtual_network_name"></a> [origin\_virtual\_network\_name](#input\_origin\_virtual\_network\_name) | (Required) The name of the origin virtual network. Changing this forces a new resource to be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_name_peering_output"></a> [destination\_name\_peering\_output](#output\_destination\_name\_peering\_output) | n/a |
| <a name="output_destination_resource_group_name_output"></a> [destination\_resource\_group\_name\_output](#output\_destination\_resource\_group\_name\_output) | n/a |
| <a name="output_destination_virtual_network_name_output"></a> [destination\_virtual\_network\_name\_output](#output\_destination\_virtual\_network\_name\_output) | n/a |
| <a name="output_origin_name_peering_output"></a> [origin\_name\_peering\_output](#output\_origin\_name\_peering\_output) | n/a |
| <a name="output_origin_resource_group_name_output"></a> [origin\_resource\_group\_name\_output](#output\_origin\_resource\_group\_name\_output) | n/a |
| <a name="output_origin_virtual_network_name_output"></a> [origin\_virtual\_network\_name\_output](#output\_origin\_virtual\_network\_name\_output) | n/a |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-peering/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-peering/_examples/basic) - Bidirectional peering between hub and spoke virtual networks.

## Resources
- [Terraform AzureRM Provider: virtual network peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering)

## Support
For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->