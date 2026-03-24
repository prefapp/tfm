<!-- BEGIN_TF_DOCS -->
# Azure Private DNS Zone Terraform Module

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

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-private-dns-zone/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-private-dns-zone/_examples/basic) - Minimal configuration for a single DNS zone and two VNet links
- [advanced](https://github.com/prefapp/tfm/tree/main/modules/azure-private-dns-zone/_examples/advanced) - Custom link prefix and registration enabled

## Resources

- **Azure Private DNS Zone**: [https://learn.microsoft.com/en-us/azure/dns/private-dns-overview](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
- **Azure Private DNS Zone Virtual Network Link**: [https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links](https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links)
- **Terraform Azure Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).

## Tag Management

By default, you can provide custom tags using the `tags` variable. If you set `tags_from_rg = true`, the module will merge the tags from the specified resource group with any extra tags you define in `tags`. This allows you to inherit tags from the resource group and add or override with your own.

**Example: Inherit and extend tags**

```hcl
module "private_dns_zone" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-private-dns-zone"

  dns_zone_name       = "privatelink.example.com"
  resource_group_name = "my-rg"
  vnet_ids            = {
    vnet1 = "<vnet1_id>"
    vnet2 = "<vnet2_id>"
  }
  tags_from_rg = true
  tags = {
    environment = "dev"
    owner       = "network-team"
  }
}
```

In this example, the final tags will be the union of the resource group's tags and the `tags` map above. If a key exists in both, the value from `tags` will take precedence.

<!-- END_TF_DOCS -->
