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
  tags_from_rg = false
}
```

### Using Resource Group Tags

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
  tags_from_rg        = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| n/a | n/a | n/a |

## Resources

| Name | Type |
|------|------|
| azurerm_dns_zone.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `dns_zone_name` | The name of the DNS zone to create. | `string` | n/a | yes |
| `resource_group_name` | The name of the resource group in which to create the DNS zone. | `string` | n/a | yes |
| `tags` | A mapping of tags to assign to the DNS zone. | `map(string)` | `{}` | no |
| `tags_from_rg` | Use the tags from the resource group. If true, the tags set in the tags variable will be ignored and the resource group tags will be used. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the DNS zone. |
| `name` | The name of the DNS zone. |
| `name_servers` | A list of name servers for the DNS zone. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples/basic) - Minimal configuration for a DNS zone

## Resources


- **Azure DNS Zone**: [https://learn.microsoft.com/en-us/azure/dns/dns-overview](https://learn.microsoft.com/en-us/azure/dns/dns-overview)
- **Terraform Azure Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
## Tag Management

By default, you can provide custom tags using the `tags` variable. If you set `tags_from_rg = true`, the module will merge the tags from the specified resource group with any extra tags you define in `tags`. This allows you to inherit tags from the resource group and add or override with your own.

**Example: Inherit and extend tags**

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
  tags_from_rg        = true
  tags = {
    environment = "dev"
    owner       = "network-team"
  }
}
```

In this example, the final tags will be the union of the resource group's tags and the `tags` map above. If a key exists in both, the value from `tags` will take precedence.
<!-- END_TF_DOCS -->