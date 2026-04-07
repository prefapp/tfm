# Azure Storage Account Terraform module (`azure-sa`)

## Overview

This module creates an **Azure Storage Account** in an existing resource group, applies **network rules** (subnets from data sources plus optional extra subnet IDs and private link access), and can provision **blob containers**, **file shares**, **queues**, **tables**, optional **lifecycle management policies**, and **Microsoft Defender for Storage** (advanced threat protection) when enabled.

The module does **not** create the resource group or virtual networks; it looks up the resource group for location/tags and resolves allowed subnets via **`azurerm_subnet`** data sources.

## Key features

- **Storage account**: Tier, replication, kind, TLS, public access, optional managed identity and blob service properties (versioning, retention, restore policy) with validations on common combinations.
- **Network**: `azurerm_storage_account_network_rules` combining subnets from `allowed_subnets`, `additional_allowed_subnet_ids`, optional IP rules, bypass, and private link access entries.
- **Data plane resources**: Optional containers, shares, queues, and tables via `for_each` maps.
- **Lifecycle**: Optional `azurerm_storage_management_policy` when `lifecycle_policy_rules` is set.
- **Tags**: `tags` map; with `tags_from_rg = true` (default is `false`), resource group tags are merged with `tags`.

## Prerequisites

- Existing **resource group** (`resource_group_name`).
- For **deny-by-default** networking, configure `allowed_subnets` and/or `additional_allowed_subnet_ids` (and/or IP rules) so the account remains reachable for your workloads.
- Storage **account name** must be **globally unique**, 3–24 characters, lowercase letters and numbers only.

## Basic usage

Pass `resource_group_name`, `storage_account`, and `network_rules`. Optional inputs default to empty/`null` where applicable; see the **Inputs** table for full types.

### Minimal example

```hcl
module "storage" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-sa?ref=<version>"

  resource_group_name = "my-resource-group"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  allowed_subnets               = []
  additional_allowed_subnet_ids = []

  storage_account = {
    name                     = "mystorageacctuniq01"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }

  network_rules = {
    default_action = "Allow"
  }
}
```

Use `default_action = "Deny"` only together with subnet/IP/private link rules that match your connectivity model.

## File structure

```
.
├── CHANGELOG.md
├── locals.tf
├── main.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
```
