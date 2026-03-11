<!-- BEGIN_TF_DOCS -->
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
    vnet_name           = "my-vnet"
    gateway_subnet_name = "GatewaySubnet"
    location            = "westeurope"
    resource_group_name = "my-rg"
    gateway_name        = "my-vpn-gw"
    ip_configurations = [
      {
        name                   = "gw-ipconfig1"
        public_ip_name         = "my-vpn-public-ip-1"
        private_ip_address_allocation = "Dynamic"
      },
      {
        name                   = "gw-ipconfig2"
        public_ip_name         = "my-vpn-public-ip-2"
        private_ip_address_allocation = "Dynamic"
      }
    ]
    type            = "Vpn"
    vpn_type        = "RouteBased"
    active_active   = true
    enable_bgp      = false
    sku             = "VpnGw1"
    # ...other optional fields...
  }
  tags = {
    environment = "dev"
    application = "example-app"
  }
  tags_from_rg = true
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
| [azurerm_virtual_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_nat_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/resources/virtual_network_gateway_nat_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.58.0/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | If true, inherit tags from the resource group. | `bool` | `false` | no |
| <a name="input_vpn"></a> [vpn](#input\_vpn) | VPN Gateway configuration object (includes P2S config) | <pre>object({<br/>    vnet_name           = optional(string)<br/>    gateway_subnet_name = optional(string)<br/>    location            = string<br/>    resource_group_name = string<br/>    gateway_name        = string<br/>    ip_configurations = list(object({<br/>      name                          = string<br/>      public_ip_name                = optional(string)<br/>      public_ip_id                  = optional(string)<br/>      private_ip_address_allocation = optional(string, "Dynamic")<br/>    }))<br/>    gateway_subnet_id                     = optional(string)<br/>    type                                  = string<br/>    vpn_type                              = string<br/>    active_active                         = bool<br/>    enable_bgp                            = bool<br/>    sku                                   = string<br/>    generation                            = optional(string)<br/>    default_local_network_gateway_id      = optional(string)<br/>    edge_zone                             = optional(string)<br/>    private_ip_address_enabled            = optional(bool)<br/>    bgp_route_translation_for_nat_enabled = optional(bool)<br/>    dns_forwarding_enabled                = optional(bool)<br/>    ip_sec_replay_protection_enabled      = optional(bool)<br/>    remote_vnet_traffic_enabled           = optional(bool)<br/>    virtual_wan_traffic_enabled           = optional(bool)<br/><br/>    # custom_route block<br/>    custom_route_address_prefixes = optional(list(string), [])<br/><br/>    # vpn_client_configuration block<br/>    vpn_client_address_space = optional(list(string), [])<br/>    vpn_client_protocols     = optional(list(string), [])<br/>    vpn_client_aad_tenant    = optional(string)<br/>    vpn_client_aad_audience  = optional(string)<br/>    vpn_client_aad_issuer    = optional(string)<br/>    root_certificates = optional(list(object({<br/>      name             = string<br/>      public_cert      = optional(string)<br/>      public_cert_data = optional(string)<br/>    })), [])<br/>    revoked_certificates = optional(list(object({<br/>      name       = string<br/>      thumbprint = string<br/>    })), [])<br/>    vpn_auth_types = optional(list(string), [])<br/><br/>    # bgp_settings block<br/>    bgp_settings = optional(object({<br/>      asn         = optional(number)<br/>      peer_weight = optional(number)<br/>      peering_addresses = optional(list(object({<br/>        ip_configuration_name = optional(string)<br/>        apipa_addresses       = optional(list(string))<br/>      })), [])<br/>    }))<br/><br/>    # timeouts block<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>    validation = {<br/>      condition = (<br/>        (try(var.vpn.gateway_subnet_id, null) != null || (try(var.vpn.gateway_subnet_name, null) != null && try(var.vpn.vnet_name, null) != null))<br/>        && alltrue([<br/>          for ipconf in var.vpn.ip_configurations : (<br/>            try(ipconf.public_ip_id, null) != null || try(ipconf.public_ip_name, null) != null<br/>          )<br/>        ])<br/>      )<br/>      error_message = "You must provide either gateway_subnet_id or both gateway_subnet_name and vnet_name, and for each ip_configuration either public_ip_id or public_ip_name."<br/>    }<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_rule_ids"></a> [nat\_rule\_ids](#output\_nat\_rule\_ids) | List of IDs of the NAT rules created (if any). |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | The IDs of the Public IPs used by the gateway. |
| <a name="output_virtual_network_gateway_id"></a> [virtual\_network\_gateway\_id](#output\_virtual\_network\_gateway\_id) | The ID of the created Virtual Network Gateway. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples):

- [basic\_route\_based](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/basic\_route\_based) - Basic RouteBased gateway example.
- [active\_active\_bgp](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/active\_active\_bgp) - Active-Active gateway with BGP enabled.
- [vpn\_client\_aad](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/vpn\_client\_aad) - Gateway with VPN Client and Azure AD authentication.

## Remote resources

- **Azure Virtual Network Gateway**: [azurerm\_virtual\_network\_gateway documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
