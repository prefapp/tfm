# Azure virtual network peering module

## Overview

This module creates a virtual network peering between two virtual networks.

## Requirements

- Resource group origin created.
- Resource group destination created.
- Virtual network origin created (VNet).
- Virtual network destination created (VNet).

## DOC

- [Resource terraform - virtual network peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering)

## Usage

### Set a module

```terraform
module "azure-vnet-peering" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-peering?ref=<version>"
}
```

#### Example

```terraform
module "azure-aks" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-vnet-peering?ref=v1.2.3"
}
```

### Set a data .tfvars

```hcl
###############
# VNET ORIGIN #
###############

origin_virtual_network_name = "origen-vnet"
origin_resource_group_name = "test-peering"
origin_name_peering = "origen-vnet-to-destino-vnet"

####################
# VNET DESTINATION #
####################

destination_virtual_network_name = "destino-vnet"
destination_resource_group_name = "test-peering"
destination_name_peering = "destino-vnet-to-origen-vnet"
```
