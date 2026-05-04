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
