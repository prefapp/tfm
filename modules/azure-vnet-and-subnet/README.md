# Azure virtual network(s) and subnet(s)

## Overview

This module creates one or more virtual networks and subnets.

## DOC

- [Resource terraform - azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Resource terraform - azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Resource terraform - azurerm_virtual_network_peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering)
- [Resource terraform - azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)
- [Resource terraform - azurerm_private_dns_zone_virtual_network_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link)

## Usage

## Observations

Al resources are created in the same resource group.

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=<version>"
}
```

#### Example

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=v1.2.3"
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `virtual_network` | Properties of the virtual network | object | n/a | yes |
| `virtual_network.name` | The name of the virtual network | string | n/a | yes |
| `virtual_network.location` | The location of the virtual network | string | n/a | yes |
| `virtual_network.address_space` | The address space of the virtual network | list(string) | n/a | yes |
| `virtual_network.subnets` | Map of subnets within the virtual network | map(object) | n/a | yes |
| `virtual_network.subnets.address_prefixes` | List of address prefixes for the subnet | list(string) | n/a | yes |
| `virtual_network.subnets.private_endpoint_network_policies_enabled` | Whether private endpoint network policies are enabled | string | `Enabled` | no |
| `virtual_network.subnets.private_link_service_network_policies_enabled` | Whether private link service network policies are enabled | bool | `true` | no |
| `virtual_network.subnets.service_endpoints` | List of service endpoints for the subnet | list(string) | `[]` | no |
| `virtual_network.subnets.delegation` | List of delegations for the subnet | list(object) | `[]` | no |
| `virtual_network.subnets.delegation.name` | The name of the delegation | string | n/a | yes |
| `virtual_network.subnets.delegation.service_delegation` | Service delegation details | object | n/a | yes |
| `virtual_network.subnets.delegation.service_delegation.name` | The name of the service delegation | string | n/a | yes |
| `virtual_network.subnets.delegation.service_delegation.actions` | List of actions for the service delegation | list(string) | n/a | yes |
| `private_dns_zones` | List of private DNS zones to create | list(object) | `[]` | no |
| `private_dns_zones.name` | The name of the private DNS zone | string | n/a | yes |
| `private_dns_zones.link_name` | The name of the private DNS zone VNET link | string | n/a | no |
| `private_dns_zones.auto_registration_enabled` | Whether auto registration is enabled | bool | `false` | no |
| `peerings` | List of virtual network peerings | list(object) | `[]` | no |
| `peerings.peering_name` | The name of the peering | string | n/a | yes |
| `peerings.allow_forwarded_traffic` | Whether forwarded traffic is allowed | bool | `false` | no |
| `peerings.allow_gateway_transit` | Whether gateway transit is allowed | bool | `false` | no |
| `peerings.allow_virtual_network_access` | Whether virtual network access is allowed | bool | `true` | no |
| `peerings.use_remote_gateways` | Whether to use remote gateways | bool | `false` | no |
| `peerings.resource_group_name` | The name of the resource group for the peering | string | n/a | yes |
| `peerings.vnet_name` | The name of the virtual network for the peering | string | n/a | yes |
| `peerings.remote_virtual_network_id` | The ID of the remote virtual network | string | n/a | yes |
| `resource_group_name` | The name of the resource group in which to create the virtual network | string | n/a | yes |
| `tags` | A map of tags to add to the public IP | map(string) | `{}` | no |
| `tags_from_rg` | Use the tags from the resource group, if true, the tags set in the tags variable will be ignored | bool | `true` | no |

### Set a data .tfvars

#### Example

```hcl
resource_group_name = "myResourceGroupName"

virtual_network = {
  name = "myVnetName"
  location = "myLocation"
  address_space = ["10.107.0.0/32"]
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
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
  }
}

private_dns_zones = [
  {
    name = "foo.councilbox.postgres.database.azure.com",
    auto_registration_enabled = true
  },
  {
    name = "privatelink.redis.cache.windows.net"
    link_name = "redis_link"
  }
]

peerings = [
  {
    peering_name = "myPeeringName"
    resource_group_name = "myResourceGroupName"
    vnet_name = "myVnetName"
    remote_virtual_network_id = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myRemoteVnetName"
  }
]

tags_from_rg = false
tags = {
  environment = "myEnvironment"
  department  = "myDepartment"
}
```

## Output

```hcl
private_dns_zone_ids = [
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net",
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/foo.councilbox.postgres.database.azure.com",
]

private_dns_zone_virtual_network_link_ids = [
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net/virtualNetworkLinks/bar-foo",
  "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/privateDnsZones/foo.bar.postgres.database.azure.com/virtualNetworkLinks/foo-bar",
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
