<!-- BEGIN_TF_DOCS -->
# **Azure Local Network Gateway Terraform Module**

## Overview

This module provisions and manages Azure Local Network Gateways for Site-to-Site VPN connections using the [azurerm\_local\_network\_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) resource. It is suitable for production, staging, and development environments, y puede integrarse en proyectos Terraform más grandes o usarse de forma independiente.

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.58.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.58.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_local_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/resources/local_network_gateway) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_localnet"></a> [localnet](#input\_localnet) | List of local network gateway objects | <pre>list(object({<br/>    local_gateway_name          = string<br/>    location                    = string<br/>    resource_group_name         = string<br/>    local_gateway_ip            = string<br/>    local_gateway_address_space = list(string)<br/>    tags_from_rg                = optional(bool)<br/>    tags                        = optional(map(string))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-localnet-gateway/_examples):

- [basic\_localnet](https://github.com/prefapp/tfm/tree/main/modules/azure-localnet-gateway/_examples/basic\_localnet) - Basic local network gateway example.
- [multiple\_address\_spaces](https://github.com/prefapp/tfm/tree/main/modules/azure-localnet-gateway/_examples/multiple\_address\_spaces) - Example with multiple address spaces.
- [with\_tags\_from\_rg](https://github.com/prefapp/tfm/tree/main/modules/azure-localnet-gateway/_examples/with\_tags\_from\_rg) - Example inheriting tags from the resource group.

## Remote resources

- **Azure Local Network Gateway**: [azurerm\_local\_network\_gateway documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->