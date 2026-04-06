# Azure Virtual Network and Subnet Terraform Module

## Overview

This Terraform module provisions and manages **Azure Virtual Networks (VNets)** and **subnets**, with optional **Private DNS zones** (including multi-VNet links), **virtual network peering**, and flexible **tagging**. It targets reusable network foundations for Azure workloads and aligns with common patterns for private endpoints, service endpoints, and subnet delegation (for example PostgreSQL Flexible Server).

The module reads an existing resource group (data source), creates the VNet and subnets from a single structured object. By default (`tags_from_rg = true`), tags on the resource group are merged with the `tags` you pass; set `tags_from_rg = false` to apply only `tags` and ignore resource group tags.

Below is a summary of the main capabilities:

- **Virtual network and subnets**: One VNet with a map of subnets; supports service endpoints, private endpoint / private link policies, and delegations.
- **Private DNS zones**: Optional zones with default linkage to the module VNet, or explicit `virtual_network_links` to attach additional VNets per zone.
- **VNet peering**: Optional peerings using `azurerm_virtual_network_peering`; peering uses the module-level `resource_group_name` and each entry’s `vnet_name` for the local VNet side.
- **Tags**: `tags` is always applied; with the default `tags_from_rg = true`, resource group tags are merged into it. Use `tags_from_rg = false` to skip that merge.

## Key Features

- **Structured network input**: `virtual_network` groups name, region, address space, and a map of subnets in one object.
- **Private DNS**: Create zones in the same resource group and manage virtual network links, including extra spokes via `virtual_network_links`.
- **Peering options**: Configure forwarded traffic, gateway transit, remote gateways, and VNet access per peering.
- **Operational clarity**: Outputs expose VNet ID, subnet IDs (keys `vnet_name.subnet_key`), private DNS zone and link IDs, and peering IDs keyed by peering name.

## Basic Usage

### Module usage

- **Prerequisites**: An Azure resource group must exist. Configure the AzureRM provider in your root module (subscription, features, and authentication as required).
- **Configure variables**: Set `resource_group_name` and the `virtual_network` object (including `subnets`). Use `private_dns_zones` and `peerings` when needed; both default to empty lists.
- **Tags**: Set `tags` as needed. Merging with resource group tags is the default (`tags_from_rg` defaults to `true`); set `tags_from_rg = false` if you want only `tags` and no inheritance from the resource group.
- **Apply**: Run `terraform init` and `terraform apply` to create or update resources.

#### Minimal example

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

#### Advanced example (service endpoints, delegation, DNS zones, peering)

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
        address_prefixes  = ["10.107.0.0/18"]
        service_endpoints = ["Microsoft.Storage"]
      }
      subnet2 = {
        address_prefixes  = ["10.107.64.0/24"]
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
      name                      = "foo.bar.postgres.database.azure.com"
      auto_registration_enabled = true
    },
    {
      name      = "privatelink.redis.cache.windows.net"
      link_name = "redis_link"
    },
    {
      name                      = "bar.com"
      auto_registration_enabled = false
      virtual_network_links = [
        {
          name               = "saas-spoke-common-predev-vnet-link"
          virtual_network_id = "/subscriptions/mySubscriptionId/resourceGroups/myResourceGroupName/providers/Microsoft.Network/virtualNetworks/myVnetName"
        },
        {
          name               = "corpme-spoke-common-predev-vnet-link"
          virtual_network_id = "/subscriptions/mySubscriptionId/resourceGroups/myOtherResourceGroupName/providers/Microsoft.Network/virtualNetworks/myOtherVnetName"
        }
      ]
    }
  ]

  peerings = [
    {
      peering_name              = "myPeeringName"
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

#### Example outputs (illustrative)

After apply, outputs may look like the following (IDs will differ in your subscription):

```hcl
private_dns_zone_ids = [
  "/subscriptions/.../privateDnsZones/privatelink.redis.cache.windows.net",
  "/subscriptions/.../privateDnsZones/foo.bar.postgres.database.azure.com",
]

subnet_ids = {
  "myVnetName.subnet1" = "/subscriptions/.../subnets/subnet1"
  "myVnetName.subnet2" = "/subscriptions/.../subnets/subnet2"
}

vnet_id = "/subscriptions/.../virtualNetworks/myVnetName"

vnet_peering_ids = {
  "myPeeringName" = "/subscriptions/.../virtualNetworkPeerings/myPeeringName"
}
```

## File structure

The module is organized as follows:

```
.
├── CHANGELOG.md
├── main.tf
├── outputs.tf
├── private_dns_zone.tf
├── private_dns_zone_vnet_link.tf
├── subnet.tf
├── variables.tf
├── vnet.tf
├── vnet-peering.tf
├── docs
│   ├── footer.md
│   └── header.md
├── README.md
└── .terraform-docs.yml
```

- **`main.tf`**: Terraform block and required provider constraints for `azurerm`.
- **`vnet.tf`**: Resource group data source and `azurerm_virtual_network`.
- **`subnet.tf`**: Subnets derived from `virtual_network.subnets`.
- **`private_dns_zone.tf`**: Private DNS zones.
- **`private_dns_zone_vnet_link.tf`**: Virtual network links for private DNS zones.
- **`vnet-peering.tf`**: Virtual network peerings.
- **`variables.tf`**: Input variables.
- **`outputs.tf`**: Exported values (VNet, subnets, DNS, peerings).
- **`docs/header.md`** / **`docs/footer.md`**: Narrative sections for `terraform-docs`.
- **`.terraform-docs.yml`**: `terraform-docs` configuration (inject into `README.md`).
