## Azure Virtual Network and Subnet Module

This Terraform module creates and manages a Virtual Network (VNet) and subnets in Azure, including private DNS zones, peerings, and tagging. It is designed for deploying complex and reusable network infrastructures in Azure environments.

### Features
- Create a VNet with multiple subnets
- Support for private DNS zones and virtual network links
- Configure network peerings
- Flexible tagging and tag inheritance from the resource group


#### Example

### Set a module

```terraform
module "githuib-oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=<version>"
}
```

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
