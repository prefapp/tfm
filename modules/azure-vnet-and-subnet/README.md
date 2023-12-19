# Azure virtual network(s) and subnet(s)

## Overview

This module creates one or more virtual networks and subnets.

## DOC

- [Resource terraform - azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Resource terraform - azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)

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

#### Example with comments

```hcl
virtual_networks = {

  // Virtual Network 1
  vnet1 = {
    location            = "westeurope" // The Azure region where the virtual network is located
    resource_group_name = "example-resources" // The name of the resource group that the virtual network belongs to
    address_space       = ["192.20.0.0/16"] // The address space of the virtual network
    subnets = {

      // Subnet 1 with multiple address prefixes
      subnet1 = {
        address_prefixes = [
          "192.20.1.0/24"
        ],
        private_endpoint_network_policies_enabled     = true // default
        private_link_service_network_policies_enabled = false
        service_endpoints = [ // The service endpoints that are associated with the subnet
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
        delegation = [ // The service delegations for the subnet
          {
            name = "delegation"
            service_delegation = {
              name = "Microsoft.Web/serverFarms" // The name of the service that the subnet is delegated to
              actions = [ // The actions that are allowed for the service delegation
                "Microsoft.Network/virtualNetworks/subnets/action"
              ]
            }
          }
        ]
      },

      // Subnet 2 without any service endpoints or delegations
      subnet2 = {
        address_prefixes = [
          "192.20.3.0/24"
        ]
      }

    }
    tags = { // The tags that are associated with the virtual network
      environment = "prod"
      department  = "finance"
    }
  },

  // Virtual Network 2 with more complex subnet configurations
  vnet2 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.30.0.0/16"]
    subnets = {

      // Subnet 1
      subnet1 = {
        address_prefixes = [
          "192.30.1.0/24"
        ],
        private_endpoint_network_policies_enabled     = false
        private_link_service_network_policies_enabled = true // default
        service_endpoints = [
          "Microsoft.ContainerRegistry",
          "Microsoft.KeyVault"
        ]
        delegation = [
          {
            name = "delegation"
            service_delegation = {
              name = "Microsoft.ContainerInstance/containerGroups"
              actions = [
                "Microsoft.Network/virtualNetworks/subnets/action"
              ]
            }
          }
        ]
      },

      // Subnet 2
      subnet2 = {
        address_prefixes = [
          "192.30.2.0/24"
        ]
      },

      // Subnet 3
      subnet3 = {
        address_prefixes = [
          "192.30.4.0/24"
        ]
      }

    }
    tags = {
      environment = "dev"
    }
  },

  // Virtual Network 3 without any subnets
  vnet3 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.40.0.0/16"]

    subnets = {} // This virtual network does not have any subnets

    tags = {
      environment = "dev"
    }
  }
}
```

#### Example without comments

```hcl
virtual_networks = {
  vnet1 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.20.0.0/16"]
    subnets = {
      subnet1 = {
        address_prefixes = [
          "192.20.1.0/24"
        ],
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = false
        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
        delegation = [
          {
            name = "delegation"
            service_delegation = {
              name = "Microsoft.Web/serverFarms"
              actions = [
                "Microsoft.Network/virtualNetworks/subnets/action"
              ]
            }
          }
        ]
      },
      subnet2 = {
        address_prefixes = [
          "192.20.3.0/24"
        ]
      }
    }
    tags = {
      environment = "prod"
      department  = "finance"
    }
  },
  vnet2 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.30.0.0/16"]
    subnets = {
      subnet1 = {
        address_prefixes = [
          "192.30.1.0/24"
        ],
        private_endpoint_network_policies_enabled     = false
        private_link_service_network_policies_enabled = true
        service_endpoints = [
          "Microsoft.ContainerRegistry",
          "Microsoft.KeyVault"
        ]
        delegation = [
          {
            name = "delegation"
            service_delegation = {
              name = "Microsoft.ContainerInstance/containerGroups"
              actions = [
                "Microsoft.Network/virtualNetworks/subnets/action"
              ]
            }
          }
        ]
      },
      subnet2 = {
        address_prefixes = [
          "192.30.2.0/24"
        ]
      },
      subnet3 = {
        address_prefixes = [
          "192.30.4.0/24"
        ]
      }
    }
    tags = {
      environment = "dev"
    }
  },
  vnet3 = {
    location            = "westeurope"
    resource_group_name = "example-resources"
    address_space       = ["192.40.0.0/16"]
    subnets = {}
    tags = {
      environment = "dev"
    }
  }
}
```

## Output

```output
vnet = {
  "vnet1" = {
    "address_space" = tolist([
      "192.20.0.0/16",
    ])
    "id" = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet1"
    "location" = "westeurope"
    "tags" = tomap({
      "department" = "finance"
      "environment" = "prod"
    })
  }
  "vnet2" = {
    "address_space" = tolist([
      "192.30.0.0/16",
    ])
    "id" = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet2"
    "location" = "westeurope"
    "tags" = tomap({
      "environment" = "dev"
    })
  }
  "vnet3" = {
    "address_space" = tolist([
      "192.40.0.0/16",
    ])
    "id" = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet3"
    "location" = "westeurope"
    "tags" = tomap({
      "environment" = "dev"
    })
  }
}
subnet = {
  "vnet1.subnet1" = {
    "address_prefixes" = tolist([
      "192.20.1.0/24",
    ])
    "id" = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1"
    "network_policies_enabled" = true
    "private_link_service_network_policies_enabled" = false
    "service_endpoints" = toset([
      "Microsoft.Sql",
      "Microsoft.Storage",
    ])
  }
  "vnet1.subnet2" = {
    "address_prefixes" = tolist([
      "192.20.3.0/24",
    ])
    "id" = "/subscriptions/e7616b70-1ad9-4968-91e0-79863ebdb96e/resourceGroups/example-resources/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet2"
    "network_policies_enabled" = true
    "private_link_service_network_policies_enabled" = true
    "service_endpoints" = toset([])
  }
}
```
