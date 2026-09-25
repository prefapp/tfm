# **Azure User Assigned Managed Identity Terraform Module**

## Overview

This module creates an **Azure user-assigned managed identity** (`azurerm_user_assigned_identity`) in an existing resource group. It can attach **Azure RBAC role assignments** to arbitrary scopes, configure **federated identity credentials** for GitHub Actions, Kubernetes workload identity, or generic OIDC issuers, use **tags** from the resource group or from a `tags` map (not both at once), and grant **Key Vault access policies** for the identity on one or more vaults.

The module does **not** create the resource group, federated issuers, or Key Vaults; it wires the identity to resources you already manage.

## Key Features

- **User-assigned identity**: Name, location, and tags. When `tags_from_rg` is **true**, identity tags are **only** those on the resource group (`var.tags` is ignored). When **false**, tags come from `var.tags`.
- **RBAC**: `rbac` entries flatten to `azurerm_role_assignment` resources, but the current implementation keys them by assignment `name` + individual `role`. Reusing the same `name` with the same `role` on different `scope` values is therefore **not currently supported** and will cause a duplicate-key error; use distinct assignment names in that case.
- **Federated credentials**: `federated_credentials` entries share `audience`; each entry has `type` `github`, `kubernetes`, or `other` (validated). The variable marks nested fields optional, but **`main.tf` expects real values per type** or plan/apply can fail: **`github`** — set `organization`, `repository`, and `entity` (subject suffix, e.g. `ref:refs/heads/main`); `issuer` defaults to the GitHub Actions OIDC issuer if unset. **`kubernetes`** — set `issuer`, `namespace`, and `service_account_name`. **`other`** — set `issuer` and `subject`.
- **Key Vault access policies**: Optional `access_policies` to grant the identity permissions on existing vaults by `key_vault_id`.
- **Outputs**: Identity **`id`**, **`name`**, **`client_id`**, and **`principal_id`** for use in AKS, role assignments, or application configuration.

## Prerequisites

- Existing **resource group** (`resource_group`) and valid **Azure region** (`location`).
- **azurerm** provider configured for your subscription (`~> 4.16.0`; see `versions.tf`).
- For **federated credentials**, issuers and subjects must match your IdP or cluster configuration.
- For **role assignments**, the deploying principal needs permission to create assignments on each `scope`.

## Basic Usage

### Example (identity only, no RBAC or federated credentials)

```hcl
module "managed_identity" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-mi?ref=<version>"

  name             = "uami-myapp-dev"
  resource_group   = "my-resource-group"
  location         = "westeurope"
  tags_from_rg     = false
  tags = {
    environment = "dev"
  }

  rbac                  = []
  federated_credentials = []
  access_policies       = []
}
```

### Example (RBAC role assignments)

```hcl
module "managed_identity_with_rbac" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-mi?ref=<version>"

  name           = "uami-myapp-reader"
  resource_group = "my-resource-group"
  location       = "westeurope"
  tags_from_rg   = false
  tags           = {}

  rbac = [
    {
      name  = "rg-reader"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group"
      roles = ["Reader"]
    },
  ]

  federated_credentials = []
  access_policies       = []
}
```

Replace `scope` and role names with values valid in your tenant. See the [comprehensive example](https://github.com/prefapp/tfm/tree/main/modules/azure-mi/_examples/comprehensive) for federated credential patterns.

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
