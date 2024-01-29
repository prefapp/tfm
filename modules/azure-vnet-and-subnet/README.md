# Azure virtual network(s) and subnet(s)

## Overview

This module creates one or more virtual networks and subnets.

## DOC

- [Resource terraform - azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Resource terraform - azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)

## Usage

### Set a module

```terraform
module "azure-vnet-and-subnet" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=<version>"
}
```

#### Example

```terraform
module "azure-vnet-and-subnet" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-subnet?ref=v1.2.3"
}
```

### Set a data .tfvars

#### Example with comments

```hcl
# VNET input variables
virtual_network_name = "test"            // The name of the virtual network.
location             = "westeurope"      // The Azure region where the virtual network is located.
resource_group       = "central-network" // The name of the resource group that the virtual network belongs to.
address_spaces       = ["10.10.0.0/16"]  // The address space of the virtual networ (CIDR notation). It's possible to specify multiple address spaces.

# Subnets input variable
subnets = {
  "aks" = {                             // The name of the subnet is a key of the map.
    address_prefixes = ["10.11.0.0/18"] // The address prefixes of the subnet (CIDR notation). It's possible to specify multiple address prefixes.
  },
  "app" = {
    address_prefixes                              = ["10.11.100.0/24"]
    private_endpoint_network_policies_enabled     = true // Enable or disable network policies for the private endpoint in the subnet. Defaults to true.
    private_link_service_network_policies_enabled = true
    service_endpoints                             = ["Microsoft.Storage"] // The list of service endpoints to associate with the subnet.
    delegation = [                                                        // The list of delegations to associate with the subnet.
      {
        name = "Microsoft.Web/serverFarms" // The name of the service to delegate to.
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"                          // The name of the service to delegate to.
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"] // The list of actions to delegate to the service.
        }
      }
    ]
  }
}
```

#### Example without comments

```hcl
# VNET input variables
virtual_network_name = "test"
location             = "westeurope"
resource_group       = "central-network"
address_spaces       = ["10.10.0.0/16"]

# Subnets input variable
subnets = {
  "aks" = {
    address_prefixes = ["10.11.0.0/18"]
  },
  "app" = {
    address_prefixes                              = ["10.11.100.0/24"]
    private_endpoint_network_policies_enabled     = true
    private_link_service_network_policies_enabled = true
    service_endpoints                             = ["Microsoft.Storage"]
    delegation = [
      {
        name = "Microsoft.Web/serverFarms"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    ]
  }
}
```

## Output

```output
# VNET outputs
output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "virtual_network_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

# Subnets output
{
  "virtual_network_name": "test"
  "virtual_network_address_space": ["10.11.0.0/16"],
  "virtual_network_id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/central-network/providers/Microsoft.Network/virtualNetworks/test",
  "subnets": {
    "aks": {
      "address_prefixes": ["10.11.0.0/18"],
      "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/central-network/providers/Microsoft.Network/virtualNetworks/test/subnets/aks",
      "network_policies_enabled": "(known after apply)",
      "private_link_service_network_policies_enabled": "(known after apply)",
      "service_endpoints": null
    },
    "app": {
      "address_prefixes": ["10.11.100.0/24"],
      "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/central-network/providers/Microsoft.Network/virtualNetworks/test/subnets/app",
      "network_policies_enabled": true,
      "private_link_service_network_policies_enabled": true,
      "service_endpoints": ["Microsoft.Storage"]
    }
  },
}
```
