<!-- BEGIN_TF_DOCS -->
# **Azure Virtual Network Gateway Connection Terraform Module**

## Overview

This module provisions and manages Azure Virtual Network Gateway Connections for Site-to-Site (S2S), VNet-to-VNet, and ExpressRoute VPNs. It supports advanced configuration, including custom IPsec/IKE policies, NAT rules, BGP, and shared key management via Azure Key Vault.

It is suitable for production, staging, and development environments, and can be integrated into larger Terraform projects or used standalone.

## Key Features

- **S2S, VNet-to-VNet, and ExpressRoute Support**: Create connections between Azure VNets, on-premises networks, or ExpressRoute circuits.
- **Custom IPsec/IKE Policies**: Fine-grained control over encryption, integrity, and key exchange settings.
- **NAT Rule Integration**: Attach ingress and egress NAT rules to connections.
- **Key Vault Integration**: Securely manage shared keys using Azure Key Vault.
- **Tag Inheritance and Customization**: Inherit tags from the resource group or specify custom tags for all resources.
- **Extensible and Modular**: Designed for easy extension and integration with other Azure network modules.

## Shared Key Management and Key Rotation

> **Important:** This module intentionally ignores changes to the `shared_key` attribute after the initial connection is created (via `lifecycle { ignore_changes = [shared_key] }`). This means:
>
> - If you rotate the Key Vault secret referenced by `keyvault_secret_name`, Terraform will **not** automatically update the VPN connection's shared key.
> - If you change the `shared_key` input value directly, Terraform will **not** apply the new value to the existing connection.
>
> This behavior is by design to prevent unintended VPN disruptions caused by accidental or automated secret updates. The shared key is only applied when the connection is first created.
>
> **To enable Terraform-managed key rotation**, you must fork or override this module and remove the `ignore_changes = [shared_key]` line from the `lifecycle` block in `main.tf`. Be aware that applying a shared key change will reconfigure the active VPN connection and may cause a brief service interruption.

## Basic Usage

See the main README and the `_examples/` directory for usage examples.

**Important:** Each connection object's `name` must be unique within the module input. This is required for stable resource addressing and to avoid accidental resource replacement if the list order changes.

```hcl
module "vnet_gateway_connection" {
  source = "./modules/azure-vnet-gateway-connection"
  connection = [{
    name                               = "example-connection"
    location                           = "westeurope"
    resource_group_name                = "example-rg"
    gateway_name                       = "example-vnet-gw"
    local_gateway_name                 = "example-local-gw"
    local_gateway_resource_group_name  = "example-local-rg"
    keyvault_vault_name                = "example-kv"
    keyvault_vault_rg                  = "example-kv-rg"
    keyvault_secret_name               = "vpn-shared-key"
    type                               = "IPsec"
    connection_mode                    = "InitiatorOnly"
    connection_protocol                = "IKEv2"
    bgp_enabled                        = false
    express_route_gateway_bypass       = false
    dpd_timeout_seconds                = 30
    routing_weight                     = 0
    use_policy_based_traffic_selectors = false
    ipsec_policy = {
      dh_group         = "DHGroup14"
      ike_encryption   = "AES256"
      ike_integrity    = "SHA256"
      ipsec_encryption = "AES256"
      ipsec_integrity  = "SHA256"
      pfs_group        = "PFS2"
      sa_datasize      = 0
      sa_lifetime      = 28800
    }
    egress_nat_rule_ids            = []
    ingress_nat_rule_ids           = []
    local_azure_ip_address_enabled = false
    tags_from_rg                   = true
    tags                           = {
      environment = "dev"
      application = "example-app"
    }
  }]
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
| [azurerm_virtual_network_gateway_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_local_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/local_network_gateway) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_network_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connection"></a> [connection](#input\_connection) | List of virtual network gateway connection objects (e.g., Site-to-Site VPN, VNet-to-VNet, ExpressRoute) | <pre>list(object({<br/>    name                               = string<br/>    location                           = string<br/>    resource_group_name                = string<br/>    local_gateway_name                 = optional(string)<br/>    local_gateway_resource_group_name  = optional(string)<br/>    type                               = string<br/>    gateway_name                       = string<br/>    shared_key                         = optional(string)<br/>    keyvault_secret_name               = optional(string)<br/>    keyvault_vault_name                = optional(string)<br/>    keyvault_vault_rg                  = optional(string)<br/>    virtual_network_gateway_id         = optional(string)<br/>    local_network_gateway_id           = optional(string)<br/>    connection_protocol                = optional(string)<br/>    routing_weight                     = optional(number)<br/>    authorization_key                  = optional(string)<br/>    express_route_circuit_id           = optional(string)<br/>    peer_virtual_network_gateway_id    = optional(string)<br/>    use_policy_based_traffic_selectors = optional(bool)<br/>    express_route_gateway_bypass       = optional(bool)<br/>    bgp_enabled                        = optional(bool)<br/>    dpd_timeout_seconds                = optional(number)<br/>    connection_mode                    = optional(string)<br/>    tags_from_rg                       = optional(bool)<br/>    egress_nat_rule_ids                = optional(list(string))<br/>    ingress_nat_rule_ids               = optional(list(string))<br/>    local_azure_ip_address_enabled     = optional(bool)<br/>    tags                               = optional(map(string))<br/>    ipsec_policy = optional(object({<br/>      dh_group         = string<br/>      ike_encryption   = string<br/>      ike_integrity    = string<br/>      ipsec_encryption = string<br/>      ipsec_integrity  = string<br/>      pfs_group        = string<br/>      sa_lifetime      = number<br/>      sa_datasize      = optional(number)<br/>    }))<br/>    custom_bgp_addresses = optional(object({<br/>      primary   = string<br/>      secondary = optional(string)<br/>    }))<br/>    private_link_fast_path_enabled = optional(bool)<br/>    traffic_selector_policy = optional(list(object({<br/>      local_address_cidrs  = list(string)<br/>      remote_address_cidrs = list(string)<br/>    })))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway-connection/_examples):

- [s2s\_basic](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway-connection/_examples/s2s\_basic) - Basic Site-to-Site connection example.
- [with\_nat\_rules](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway-connection/_examples/with\_nat\_rules) - Example with ingress/egress NAT rules.
- [with\_keyvault\_shared\_key](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway-connection/_examples/with\_keyvault\_shared\_key) - Example using Azure Key Vault for shared key management.

## Remote resources

- **Azure Virtual Network Gateway Connection**: [azurerm\_virtual\_network\_gateway\_connection documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection)
- **Azure Key Vault Secret**: [azurerm\_key\_vault\_secret documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
