<!-- BEGIN_TF_DOCS -->
# Azure DNS Zone Terraform Module

## Overview

This module provisions a standard Azure DNS Zone. It is designed for scenarios where you need to manage public DNS zones for your domains in Azure, supporting use cases such as application hosting, hybrid cloud, and multi-environment deployments (dev, staging, production).

Key capabilities include:
- Automated creation of a DNS zone
- Tagging support for resource management
- Integration with Azure Resource Groups

This module is ideal for teams seeking a simple, reusable way to manage DNS zones as code.

## Key Features

- **DNS Zone Creation**: Provisions a standard Azure DNS Zone.
- **Tagging Support**: Allows custom tags for resource organization.
- **Resource Group Integration**: DNS zone is created in the specified resource group.

## Basic Usage

### Minimal Example

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
}
```

### With Custom Tags

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
  tags = {
    environment = "production"
    owner       = "network-team"
  }
}
```

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples/basic) - Minimal configuration for a DNS zone
- [tags](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples/tags) - DNS zone with custom tags

## Resources

- **Azure DNS Zone**: [https://learn.microsoft.com/en-us/azure/dns/dns-overview](https://learn.microsoft.com/en-us/azure/dns/dns-overview)
- **Terraform Azure Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->