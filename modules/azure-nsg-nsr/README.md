<!-- BEGIN_TF_DOCS -->
# Azure NSG + rules Terraform module (`azure-nsg-nsr`)

## Overview

This module creates one **network security group** (`azurerm_network_security_group`) and **security rules** (`azurerm_network_security_rule`, `for_each` over `rules`) in an existing resource group.

Optional **tag merge** from the resource group uses `tags_from_rg` (default **`false`**).

## Rule fields (prefix / range exclusivity)

For each rule, Terraform enforces **not** setting both members of a pair at once. Omitting both is allowed by the module, but Azure typically needs at least one value per pair for the rule to apply correctly:

- `source_port_range` **or** `source_port_ranges`
- `destination_port_range` **or** `destination_port_ranges`
- `source_address_prefix` **or** `source_address_prefixes`
- `destination_address_prefix` **or** `destination_address_prefixes`

Do not set both members of a pair on the same rule.

## Prerequisites

- Existing **resource group** (`nsg.resource_group_name`).
- **azurerm** provider configured.

## Basic usage

```hcl
module "nsg" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-nsg-nsr?ref=<version>"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  nsg = {
    name                = "example-nsg"
    location            = "westeurope"
    resource_group_name = "example-rg"
  }

  rules = {
    ssh = {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/24"
      destination_address_prefix = "*"
    }
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
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nsg"></a> [nsg](#input\_nsg) | NSG name, location, and resource group (group must exist). | <pre>object({<br/>    name                = string<br/>    location            = string<br/>    resource_group_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | Map of security rules (map keys are arbitrary; rule `name` is the Azure rule name). Use either `*_range` or `*_ranges` / `*_prefix` or `*_prefixes` per field, not both. | <pre>map(object({<br/>    name                         = string<br/>    priority                     = number<br/>    direction                    = string<br/>    access                       = string<br/>    protocol                     = string<br/>    source_port_range            = optional(string)<br/>    source_port_ranges           = optional(list(string))<br/>    destination_port_range       = optional(string)<br/>    destination_port_ranges      = optional(list(string))<br/>    source_address_prefix        = optional(string)<br/>    source_address_prefixes      = optional(list(string))<br/>    destination_address_prefix   = optional(string)<br/>    destination_address_prefixes = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the network security group. |

## Examples

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples/basic) — Minimal NSG + two rules.
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-nsg-nsr/_examples/comprehensive) — **`values.reference.yaml`**: same shape as HCL (illustrative).

## Remote resources

- **Terraform `azurerm_network_security_group`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- **Terraform `azurerm_network_security_rule`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->
