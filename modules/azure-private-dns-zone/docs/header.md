
# **Azure Private DNS Zone Terraform Module**

## Overview

This module provisions an Azure Private DNS Zone and links it to multiple Virtual Networks (VNets). It simplifies DNS management for split-horizon scenarios, enabling centralized DNS resolution across development, staging, and production environments. The module supports flexible topologies, secure name resolution, and easy integration with Azure Resource Groups.

Key capabilities include:
- Automated creation of a single DNS zone
- Dynamic linking to multiple VNets
- Optional registration-enabled links
- Customizable link naming
- Resource group integration

Ideal for microservices, hybrid cloud, and multi-environment deployments where DNS centralization is required.

## Key Features

- **Single DNS Zone Creation**: Provisions one Azure Private DNS Zone per module instance.
- **Multiple VNet Links**: Links the DNS zone to any number of VNets using a map input.
- **Registration Enabled Option**: Allows enabling registration for each link.
- **Custom Link Naming**: Supports custom prefix for link names.
- **Resource Group Integration**: DNS zone and links are created in the specified resource group.

## Basic Usage

### Minimal Example

```hcl
module "private_dns_zone" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-private-dns-zone"

  dns_zone_name       = "privatelink.example.com"
  resource_group_name = "my-rg"
  vnet_ids            = {
    vnet1 = "<vnet1_id>"
    vnet2 = "<vnet2_id>"
  }
}
```

### Advanced Example (Custom Link Prefix & Registration)

```hcl
module "private_dns_zone" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-private-dns-zone"

  dns_zone_name        = "privatelink.example.com"
  resource_group_name  = "my-rg"
  vnet_ids             = {
    dev = "<dev_vnet_id>"
    prod = "<prod_vnet_id>"
  }
  link_name_prefix     = "customlink"
  registration_enabled = true
}
```
