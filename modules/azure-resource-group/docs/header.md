# Azure resource group Terraform module (`azure-resource-group`)

## Overview

This module creates a single **Azure resource group** (`azurerm_resource_group`). It is a thin wrapper around the provider resource with stable outputs and a `moved` block for state migration from the legacy resource address `azurerm_resource_group.resorce_group`.

## Key features

- **Single resource group**: `name`, `location`, and optional `tags`.
- **State migration**: `moved` from `azurerm_resource_group.resorce_group` to `azurerm_resource_group.this` (see `resource_groups.tf`).

## Prerequisites

- **azurerm** provider configured for your subscription.
- Valid **region** name for `location` (Azure REST naming, e.g. `westeurope`).

## Basic usage

```hcl
module "resource_group" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-resource-group?ref=<version>"

  name     = "my-app-rg"
  location = "westeurope"
  tags = {
    environment = "dev"
  }
}
```

## File structure

```
.
├── CHANGELOG.md
├── resource_groups.tf
├── variables.tf
├── versions.tf
├── outputs.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   └── basic
├── README.md
└── .terraform-docs.yml
```
