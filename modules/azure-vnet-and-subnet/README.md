<!-- BEGIN_TF_DOCS -->
## Azure Virtual Network and Subnet Module

This Terraform module creates and manages a Virtual Network (VNet) and subnets in Azure, including private DNS zones, peerings, and tagging. It is designed for deploying complex and reusable network infrastructures in Azure environments.

### Features
- Create a VNet with multiple subnets
- Support for private DNS zones and virtual network links
- Configure network peerings
- Flexible tagging and tag inheritance from the resource group

### Basic example

```hcl
module "azure_vnet_and_subnet" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-and-subnet?ref=<version>"

  resource_group_name = "example-rg"

  virtual_network = {
    name          = "example-vnet"
    location      = "westeurope"
    address_space = ["10.0.0.0/16"]
    subnets = {
      internal = {
        address_prefixes = ["10.0.1.0/24"]
      }
    }
  }

  private_dns_zones = []
  peerings          = []

  tags = {
    environment = "dev"
  }
}
```

### Advanced example

```hcl
module "azure_vnet_and_subnet" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-and-subnet?ref=<version>"

  resource_group_name = "myResourceGroupName"

  virtual_network = {
    name          = "myVnetName"
    location      = "myLocation"
    address_space = ["10.107.0.0/16"]
    subnets = {
      subnet1 = {
        address_prefixes = ["10.107.0.0/18"]
        service_endpoints = ["Microsoft.Storage"]
      }
      subnet2 = {
        address_prefixes = ["10.107.64.0/24"]
        service_endpoints = ["Microsoft.Storage"]
        delegation = [
          {
            name = "Microsoft.DBforPostgreSQL.flexibleServers"
            service_delegation = {
              name    = "Microsoft.DBforPostgreSQL/flexibleServers"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        ]
      }
    }
  }

  private_dns_zones = [
    {
      name                      = "foo.councilbox.postgres.database.azure.com"
      auto_registration_enabled = true
    },
    {
      name      = "privatelink.redis.cache.windows.net"
      link_name = "redis_link"
    }
  ]

  peerings = [
    {
      peering_name              = "myPeeringName"
      resource_group_name       = "myResourceGroupName"
      vnet_name                 = "myVnetName"
      remote_virtual_network_id = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myRemoteVnetName"
    }
  ]

  tags_from_rg = false
  tags = {
    environment = "myEnvironment"
    department  = "myDepartment"
  }
}
```

## Output

```hcl
private_dns_zone_ids = [
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net",
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/foo.councilbox.postgres.database.azure.com",
]

private_dns_zone_virtual_network_link_ids = [
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net/virtualNetworkLinks/redis_link",
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/foo.councilbox.postgres.database.azure.com/virtualNetworkLinks/redis_link",
]

subnet_ids = {
  "myVnetName.subnet1" = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myVnetName/subnets/subnet1"
  "myVnetName.subnet2" = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myVnetName/subnets/subnet2"
}

vnet_id = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myVnetName"
vnet_peering_ids = {
  "myPeeringName" = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myVnetName/virtualNetworkPeerings/myPeeringName"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.21.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.21.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_peerings"></a> [peerings](#input\_peerings) | List of virtual network peerings | <pre>list(object({<br/>    peering_name                 = string<br/>    allow_forwarded_traffic      = optional(bool, false)<br/>    allow_gateway_transit        = optional(bool, false)<br/>    allow_virtual_network_access = optional(bool, true)<br/>    use_remote_gateways          = optional(bool, false)<br/>    resource_group_name          = string<br/>    vnet_name                    = string<br/>    remote_virtual_network_id    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | List of private DNS zones to create | <pre>list(object({<br/>    name                      = string<br/>    link_name                 = optional(string)<br/>    auto_registration_enabled = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the virtual network | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to associate with your resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use the tags from the resource group | `bool` | `true` | no |
| <a name="input_virtual_network"></a> [virtual\_network](#input\_virtual\_network) | Properties of the virtual network | <pre>object({<br/>    name          = string<br/>    location      = string<br/>    address_space = list(string)<br/>    subnets = map(object({<br/>      address_prefixes                              = list(string)<br/>      private_endpoint_network_policies_enabled     = optional(string, "Enabled")<br/>      private_link_service_network_policies_enabled = optional(bool, true)<br/>      service_endpoints                             = optional(list(string))<br/>      delegation = optional(list(object({<br/>        name = string<br/>        service_delegation = object({<br/>          name    = string<br/>          actions = list(string)<br/>        })<br/>      })))<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Output the IDs of the private DNS zones |
| <a name="output_private_dns_zone_virtual_network_link_ids"></a> [private\_dns\_zone\_virtual\_network\_link\_ids](#output\_private\_dns\_zone\_virtual\_network\_link\_ids) | Output the IDs of the private DNS zone virtual network links |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Output the IDs of the subnets with their names as keys |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Output the ID of the virtual network |
| <a name="output_vnet_peering_ids"></a> [vnet\_peering\_ids](#output\_vnet\_peering\_ids) | Output the IDs of the virtual network peerings with their names as keys |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-and-subnet/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-and-subnet/_examples/basic) - Virtual network with one internal subnet.

## Resources
- [Official Azure Virtual Network documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)

## Support
For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->