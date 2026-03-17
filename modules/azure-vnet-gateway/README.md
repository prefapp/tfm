<!-- BEGIN_TF_DOCS -->
# **Azure Virtual Network Gateway Terraform Module**

## Overview

This module provisions and manages an Azure Virtual Network Gateway for VPN connectivity, supporting both Route-based and Policy-based configurations. It is suitable for production, staging, and development environments, and can be integrated into larger Terraform projects or used standalone.

## Key Features

- **Flexible Gateway Deployment**: Supports Route-based and Policy-based VPN gateways, active-active mode, and multiple SKUs.
- **Custom IP Configuration**: Allows custom public IP, subnet, and private IP allocation.
- **Advanced VPN Client Support**: Configure VPN client address spaces, protocols, and AAD integration for P2S.
- **NAT Rules Support**: Allows defining NAT rules for address translation on the gateway.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Extensible and Modular**: Designed for easy extension and integration with other Azure network modules.

## Basic Usage

See the main README and the `_examples/` directory for usage examples.

```hcl
module "vnet_gateway" {
  source = "../../"
  vpn = {
    vnet_name                             = "example-vnet"
    gateway_subnet_name                   = "GatewaySubnet"
    location                              = "westeurope"
    resource_group_name                   = "example-rg"
    gateway_name                          = "example-vpn-gw"
    ip_configurations = [
      {
        name                   = "gw-ipconfig1"
        public_ip_name         = "example-vpn-public-ip-1"
        private_ip_address_allocation = "Dynamic"
      },
      {
        name                   = "gw-ipconfig2"
        public_ip_name         = "example-vpn-public-ip-2"
        private_ip_address_allocation = "Dynamic"
      }
    ]
    type                                  = "Vpn"
    vpn_type                              = "RouteBased"
    active_active                         = true
    bgp_enabled                           = true
    bgp_settings = {
      asn = 65515
      peer_weight = 0
      peering_addresses = [
        {
          ip_configuration_name = "gw-ipconfig1"
          apipa_addresses = ["169.254.21.2"]
        },
        {
          ip_configuration_name = "gw-ipconfig2"
          apipa_addresses = ["169.254.21.3"]
        }
      ]
    }
    sku                                   = "VpnGw2"
    bgp_route_translation_for_nat_enabled = true
  }
  nat_rules = [
    {
      name = "egress-nat"
      mode = "EgressSnat"
      type = "Static"
      external_mapping = [
        {
          address_space = "203.0.113.0/24"
          port_range    = "1-65535"
        }
      ]
      internal_mapping = [
        {
          address_space = "10.0.0.0/24"
          port_range    = "1-65535"
        }
      ]
    }
  ]
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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.64.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.64.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_nat_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_nat_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nat_rules"></a> [nat\_rules](#input\_nat\_rules) | List of NAT rules to apply to the VPN Gateway. Each rule must have: name, mode, type, external\_mapping, and internal\_mapping. Optional field is ip\_configuration\_id. external\_mapping and internal\_mapping are lists of mappings with address\_space and optional port\_range. mode and type are required. | <pre>list(object({<br/>    name                = string<br/>    mode                = string<br/>    type                = string<br/>    ip_configuration_id = optional(string)<br/>    external_mapping = list(object({<br/>      address_space = string<br/>      port_range    = optional(string)<br/>    }))<br/>    internal_mapping = list(object({<br/>      address_space = string<br/>      port_range    = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | If true, inherit tags from the resource group. | `bool` | `false` | no |
| <a name="input_vpn"></a> [vpn](#input\_vpn) | VPN Gateway configuration object (includes P2S config) | <pre>object({<br/>    vnet_name           = optional(string)<br/>    gateway_subnet_name = optional(string)<br/>    location            = string<br/>    resource_group_name = string<br/>    gateway_name        = string<br/>    ip_configurations = list(object({<br/>      name                          = string<br/>      public_ip_name                = optional(string)<br/>      public_ip_id                  = optional(string)<br/>      private_ip_address_allocation = optional(string, "Dynamic")<br/>    }))<br/>    gateway_subnet_id                     = optional(string)<br/>    type                                  = string<br/>    vpn_type                              = optional(string)<br/>    active_active                         = optional(bool)<br/>    bgp_enabled                           = optional(bool)<br/>    sku                                   = string<br/>    generation                            = optional(string)<br/>    default_local_network_gateway_id      = optional(string)<br/>    edge_zone                             = optional(string)<br/>    private_ip_address_enabled            = optional(bool)<br/>    bgp_route_translation_for_nat_enabled = optional(bool)<br/>    dns_forwarding_enabled                = optional(bool)<br/>    ip_sec_replay_protection_enabled      = optional(bool)<br/>    remote_vnet_traffic_enabled           = optional(bool)<br/>    virtual_wan_traffic_enabled           = optional(bool)<br/><br/>    # custom_route block<br/>    custom_route_address_prefixes = optional(list(string), [])<br/><br/>    # vpn_client_configuration block<br/>    vpn_client_address_space = optional(list(string), [])<br/>    vpn_client_protocols     = optional(list(string), [])<br/>    vpn_client_aad_tenant    = optional(string)<br/>    vpn_client_aad_audience  = optional(string)<br/>    vpn_client_aad_issuer    = optional(string)<br/>    root_certificates = optional(list(object({<br/>      name             = string<br/>      public_cert      = optional(string)<br/>      public_cert_data = optional(string)<br/>    })), [])<br/>    revoked_certificates = optional(list(object({<br/>      name       = string<br/>      thumbprint = string<br/>    })), [])<br/>    vpn_auth_types = optional(list(string), [])<br/><br/>    # bgp_settings block<br/>    bgp_settings = optional(object({<br/>      asn         = optional(number)<br/>      peer_weight = optional(number)<br/>      peering_addresses = optional(list(object({<br/>        ip_configuration_name = optional(string)<br/>        apipa_addresses       = optional(list(string))<br/>      })), [])<br/>    }))<br/><br/>    # timeouts block<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_rule_ids"></a> [nat\_rule\_ids](#output\_nat\_rule\_ids) | List of IDs of the NAT rules created (if any). |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | The IDs of the Public IPs used by the gateway. |
| <a name="output_virtual_network_gateway_id"></a> [virtual\_network\_gateway\_id](#output\_virtual\_network\_gateway\_id) | The ID of the created Virtual Network Gateway. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples):

- [basic\_route\_based](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/basic\_route\_based) - Basic RouteBased gateway example.
- [active\_active\_bgp\_and\_nat\_rules](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/active\_active\_bgp\_and\_nat\_rules) - Active-Active gateway with BGP enabled.
- [vpn\_client\_aad](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/vpn\_client\_aad) - Gateway with VPN Client and Azure AD authentication.

## Remote resources

- **Azure Virtual Network Gateway**: [azurerm\_virtual\_network\_gateway documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)
- **NAT Rule**: [azurerm\_virtual\_network\_gateway\_nat\_rule documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway\_nat\_rule)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
