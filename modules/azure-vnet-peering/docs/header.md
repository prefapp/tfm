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
