# **Azure Key Vault Terraform Module** (`azure-kv`)

## Overview

This module creates an **Azure Key Vault** (`azurerm_key_vault`) in an **existing resource group**. It supports **Azure RBAC** on the vault or **classic access policies**, optional resolution of principals via **Azure AD** data sources (user, group, or service principal by display or UPN), tag merge from the resource group, and lifecycle **preconditions** so access policies are not mixed with RBAC when that combination is invalid.

The module does **not** create the resource group, private endpoints, or key/secret/certificate resources; consumers add those separately if needed.

## Key features

- **Key Vault**: SKU, soft delete retention, purge protection, disk encryption integration, tenant binding.
- **Authorization model**: `enable_rbac_authorization` toggles between RBAC and access policies; when RBAC is enabled, `access_policies` must be empty.
- **Access policies**: Optional list; each entry must set a **non-empty, unique `name`** (the module uses it as a `for_each` key and for Azure AD lookups). Use `type` (`user`, `group`, `service_principal`) plus `name`, or `object_id` with empty `type` for a direct principal.
- **Outputs**: Resource `id`, `name`, `vault_uri`, `location`, `resource_group_name`, and `tenant_id` for wiring apps, DNS, or role assignments.

## Prerequisites

- Existing **resource group** (`resource_group`); the module reads it for location and optional tag inheritance.
- **Key Vault name** must be **globally unique**, 3–24 characters, alphanumeric.
- **Azure AD provider** is required by the module declaration; configure `provider "azuread"` in the root module even when using RBAC-only (no access policy lookups).
- For **access policies** with principal lookup, principals must exist and be resolvable (correct UPN, group display name, or service principal display name).

## Basic usage

Point `source` at this module and set required inputs. Use **RBAC** (`enable_rbac_authorization = true`) with an empty `access_policies` list for the smallest surface, or **access policies** with `enable_rbac_authorization = false`.

### Minimal example (RBAC on the vault)

```hcl
module "key_vault" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=<version>"

  name                         = "kv-myapp-dev01"
  resource_group               = "my-resource-group"
  enabled_for_disk_encryption  = false
  soft_delete_retention_days   = 7
  purge_protection_enabled     = false
  sku_name                     = "standard"
  enable_rbac_authorization    = true
  access_policies              = []

  tags_from_rg = false
  tags = {
    environment = "dev"
  }
}
```

Assign **Key Vault data plane** or **management** roles at scope vault or above when using RBAC; this module does not create role assignments.

## File structure

```
.
├── CHANGELOG.md
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
