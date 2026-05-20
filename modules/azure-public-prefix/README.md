<!-- BEGIN_TF_DOCS -->
# Azure public IP prefix Terraform module (`azure-public-prefix`)

## Overview

This module creates an **`azurerm_public_ip_prefix`** in an existing resource group. Public IP prefixes provide a contiguous range of public addresses for use with Standard SKU public IPs (NAT gateways, load balancers, etc.).

Optional **tag merge** from the resource group is available via `tags_from_rg`.

## Key features

- **Standard SKU** public IP prefix with configurable **prefix length**, **IP version** (IPv4/IPv6), **SKU tier** (Regional/Global), and optional **availability zones**.
- **Tags**: `tags` plus optional merge from the resource group when `tags_from_rg = true`.

## Prerequisites

- Existing **resource group** (`resource_group_name`).
- **azurerm** provider configured.

## Basic usage

```hcl
module "public_ip_prefix" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-public-prefix?ref=<version>"

  name                = "example-prefix"
  resource_group_name = "example-rg"
  location            = "westeurope"

  prefix_length = 29
  zones         = ["1"]

  tags_from_rg = false
  tags = {
    environment = "dev"
  }
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
├── locals.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip_prefix.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_version"></a> [ip\_version](#input\_ip\_version) | The IP version of the Public IP Prefix. | `string` | `"IPv4"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the Public IP Prefix is created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Public IP Prefix. | `string` | n/a | yes |
| <a name="input_prefix_length"></a> [prefix\_length](#input\_prefix\_length) | The length of the Public IP Prefix. | `number` | `28` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Public IP Prefix. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Public IP Prefix. | `string` | `"Standard"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier of the Public IP Prefix. | `string` | `"Regional"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The availability zone to allocate the Public IP Prefix in. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the public IP prefix. |
| <a name="output_ip_prefix"></a> [ip\_prefix](#output\_ip\_prefix) | IP prefix range allocated by Azure (CIDR notation). |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-public-prefix/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-public-prefix/_examples/basic) — Minimal module call for one public IP prefix; set RG, location, and prefix options per Azure constraints (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-public-prefix/_examples/comprehensive) — Illustrative `values.reference.yaml` for module inputs (documentation-oriented; see folder README).

## Resources

Terraform resource docs use **4.16.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.16.0`).

- **Public IP address prefix (Azure)**: [https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-address-prefix](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-address-prefix)
- **azurerm\_public\_ip\_prefix**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/public_ip_prefix](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/public_ip_prefix)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->