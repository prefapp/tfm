# **Azure Local Network Gateway Terraform Module**

## Overview

This module provisions and manages Azure Local Network Gateways for Site-to-Site VPN connections using the [azurerm_local_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) resource. It is suitable for production, staging, and development environments, y puede integrarse en proyectos Terraform más grandes o usarse de forma independiente.

## Key Features

- **Multiple Gateway Support**: Create one or more Azure Local Network Gateways with flexible configuration.
- **Custom Address Spaces**: Define custom address spaces and gateway IPs for each local network.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Extensible and Modular**: Designed for easy extension and integration with other Azure network modules.

## Basic Usage

See the main README and the `_examples/` directory for usage examples.

```hcl
module "localnet_gateway" {
  source = "./modules/azure-localnet-gateway"
  localnet = [
    {
      local_gateway_name          = "example-gateway"
      location                    = "westeurope"
      resource_group_name         = "example-rg"
      local_gateway_ip            = "203.0.113.1"
      local_gateway_address_space = ["10.1.0.0/16"]
      tags_from_rg                = true
      tags                        = {
        environment = "dev"
      }
    }
  ]
}
```
