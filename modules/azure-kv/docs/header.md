# Azure Key Vault (`azure-kv`)

## Overview

Creates one **Key Vault** (`azurerm_key_vault`) in an existing resource group. You choose either **Azure RBAC** for the data plane (`enable_rbac_authorization = true`) or **classic access policies** (`enable_rbac_authorization = false`).

When RBAC is enabled, **`access_policies` must be empty**; otherwise the module fails with a lifecycle precondition.

## Tags

If **`tags_from_rg`** is `true`, tags are **`merge(resource_group.tags, var.tags)`** (values in `var.tags` win on duplicate keys). If `false`, only **`var.tags`** are applied.

## Access policies (RBAC disabled)

Each list entry must have a **unique, non-empty `name`** (internal map key).

- **`object_id` set** (non-empty): that principal is used; no Entra ID lookup.
- **`type`** one of **`user`**, **`group`**, **`service_principal`**: `name` is the UPN or display name resolved via `azuread_*` data sources.

Permission lists default to empty lists in the resource if omitted.

## Prerequisites

- Existing **resource group**.
- **azurerm** and **azuread** providers configured (data sources need appropriate directory read permissions when resolving principals).

## Basic usage

```hcl
module "kv" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=<version>"

  name                        = "examplekv001"
  resource_group              = "example-rg"
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = false

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  access_policies = [
    {
      name                    = "bootstrap-principal"
      object_id               = "00000000-0000-0000-0000-000000000000"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = []
      storage_permissions     = []
    }
  ]
}
```

## File structure

```
.
├── CHANGELOG.md
├── main.tf
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
