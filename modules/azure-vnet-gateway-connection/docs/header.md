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
