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

### Set a data .tfvars

#### Example

```hcl
tags_from_rg = false
tags = {
  environment = "myEnvironment"
  department  = "myDepartment"
}
location = "myLocation"
resource_group_name = "myResourceGroupName"
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
          name = "Microsoft.DBforPostgreSQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    ]
  }
}
private_dns_zones = [
  {
    name = "foo.councilbox.postgres.database.azure.com"
  },
  {
    name = "privatelink.redis.cache.windows.net"
  }
]
private_dns_zone_virtual_network_links = {
  "foo.bar.postgres.database.azure.com" = {
    name = "foo-bar"
    private_dns_zone_name = "foo.bar.postgres.database.azure.com"
  }
  "bar.foo.privatelink.redis.cache.windows.net" = {
    name = "bar-foo"
    private_dns_zone_name = "bar.foo.privatelink.redis.cache.windows.net"
    registration_enabled = false
  }
}
peerings = [
  {
    peering_name = "myPeeringName"
    resource_group_name = "myResourceGroupName"
    vnet_name = "myVnetName"
    remote_virtual_network_id = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myRemoteVnetName"
  }
]
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
