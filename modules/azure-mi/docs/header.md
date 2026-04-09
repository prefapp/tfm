# Azure user-assigned managed identity (`azure-mi`)

## Overview

This module creates a **user-assigned managed identity** (`azurerm_user_assigned_identity`) and can attach:

- **RBAC role assignments** (`azurerm_role_assignment`) from a flattened `name` / `scope` / `roles` list
- **Federated identity credentials** (`azurerm_federated_identity_credential`) for GitHub Actions, Kubernetes workload identity, or custom issuers (`type`: `github`, `kubernetes`, `other`)
- **Key Vault access policies** (`azurerm_key_vault_access_policy`) when `access_policies` is non-empty

Tags: if `tags_from_rg` is **`true`**, tags come from the resource group data source; otherwise **`tags`** are used (default **`{}`**).

## Federated credentials

| `type` | Behaviour |
|--------|-----------|
| `github` | `issuer` defaults to `https://token.actions.githubusercontent.com` if omitted. `subject` is `repo:{organization}/{repository}:{entity}`; if `entity` is omitted it defaults to `ref:refs/heads/main`. |
| `kubernetes` | `subject` is `system:serviceaccount:{namespace}:{service_account_name}`. |
| `other` | You must set `issuer` and `subject`. |

`audience` applies to all federated credentials (default `["api://AzureADTokenExchange"]`).

## Key Vault access policies

Each object in `access_policies` becomes one policy. The module keys policies by `key_vault_id`, so **at most one entry per Key Vault** in the list.

## Prerequisites

- Existing **resource group** (`resource_group`).
- **azurerm** provider configured.

## Basic usage

```hcl
module "mi" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-mi?ref=<version>"

  name           = "example-mi"
  resource_group = "example-rg"
  location       = "westeurope"

  tags_from_rg = false
  tags = {
    environment = "dev"
  }

  rbac = [
    {
      name  = "sub-contributor"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
      roles = ["Reader"]
    }
  ]

  federated_credentials = []
  access_policies       = []
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
