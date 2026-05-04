# **Azure Key Vault Terraform Module**

## Overview

This module creates an **Azure Key Vault** (`azurerm_key_vault`) in an **existing resource group**. It supports **Azure RBAC** on the vault or **classic access policies**, optional resolution of principals via **Azure AD** data sources (user, group, or service principal by display name or UPN), tag merge from the resource group, and lifecycle **preconditions** so access policies are not mixed with RBAC when that combination is invalid.

The module does **not** create the resource group, private endpoints, or key/secret/certificate resources; consumers add those separately if needed. Use it when you want a small, opinionated wrapper around `azurerm_key_vault` with consistent tagging and access-policy wiring for teams that still use vault access policies or are migrating toward vault-level RBAC.

## Key Features

- **Key Vault**: SKU, soft delete retention, purge protection, disk encryption integration, tenant binding.
- **Authorization model**: `enable_rbac_authorization` toggles between RBAC and access policies; when RBAC is enabled, `access_policies` must be empty.
- **Access policies**: Optional list; each entry must set a **non-empty, unique `name`** (the module uses it as a `for_each` key and for Azure AD lookups). Use `type` (`user`, `group`, `service_principal`) plus `name`, or `object_id` with empty `type` for a direct principal.
- **Outputs**: Exposes the Key Vault **`id`** for downstream resources, role assignments, or references that need the Azure resource identifier.

## Prerequisites

- Existing **resource group** (`resource_group`); the module reads it for location and optional tag inheritance.
- **Key Vault name** must be **globally unique**, 3–24 characters, and use only letters, numbers, and hyphens.
- The module lists **`azuread`** in `required_providers`; your root module must declare **`azuread`** (and usually `provider "azuread" {}`) so Terraform can initialize the tree. **Azure AD data sources** in this module run only for access policies that use `type` `user`, `group`, or `service_principal`; entries that only set `object_id` (with empty `type`) do not perform those lookups.
- For **access policies** with principal lookup, principals must exist and be resolvable (correct UPN, group display name, or service principal display name).

## Basic Usage

Point `source` at this module and set required inputs. Use **RBAC** (`enable_rbac_authorization = true`) with an empty `access_policies` list for the smallest surface, or **access policies** with `enable_rbac_authorization = false`.

### Example (RBAC on the vault)

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

Assign **Key Vault data plane** or **management** roles at vault scope or above when using RBAC; this module does not create role assignments.

### Example (access policies, RBAC disabled)

```hcl
module "key_vault_access_policies" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=<version>"

  name                         = "kv-myapp-legacy01"
  resource_group               = "my-resource-group"
  enabled_for_disk_encryption  = false
  soft_delete_retention_days   = 7
  purge_protection_enabled     = false
  sku_name                     = "standard"
  enable_rbac_authorization    = false

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  access_policies = [
    {
      name                    = "workload-spn"
      type                    = ""
      object_id               = "11111111-1111-1111-1111-111111111111"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    },
  ]
}
```

Replace `object_id` with a real principal in your tenant. To resolve principals by **UPN / display name** instead, set `type` to `user`, `group`, or `service_principal` and set `name` accordingly; that path uses the Azure AD provider data sources.

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
