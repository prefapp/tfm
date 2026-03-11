# **Azure Virtual Network Gateway Terraform Module**

## Overview

This module provisions and manages an Azure Virtual Network Gateway for VPN connectivity, supporting both Route-based and Policy-based configurations. It is suitable for production, staging, and development environments, and can be integrated into larger Terraform projects or used standalone.

## Key Features

- **Flexible Gateway Deployment**: Supports Route-based and Policy-based VPN gateways, active-active mode, and multiple SKUs.
- **Custom IP Configuration**: Allows custom public IP, subnet, and private IP allocation.
- **Advanced VPN Client Support**: Configure VPN client address spaces, protocols, and AAD integration for P2S.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Extensible and Modular**: Designed for easy extension and integration with other Azure network modules.

## Basic Usage

See the main README and the `_examples/` directory for usage examples.

```hcl
module "vnet_gateway" {
  source = "./modules/azure-vnet-gateway"
  vpn = {
    vnet_name                     = "my-vnet"
    gateway_subnet_name           = "GatewaySubnet"
    location                      = "westeurope"
    resource_group_name           = "my-rg"
    gateway_name                  = "my-vpn-gw"
    ip_name                       = "my-vpn-ip"
    public_ip_name                = "my-vpn-public-ip"
    private_ip_address_allocation = "Dynamic"
    type                          = "Vpn"
    vpn_type                      = "RouteBased"
    active_active                 = false
    enable_bgp                    = false
    sku                           = "VpnGw1"
    # ...other optional fields...
  }
}
```
