# `azure-kv`

## Overview

Terraform module that creates an **Azure Key Vault** (`azurerm_key_vault`) in an existing resource group, with optional **access policies** resolved from **Entra ID** (`azuread` data sources for users, groups, and service principals) or **direct `object_id`**, and optional **tag merge** from the resource group.

**Prerequisites**

- Existing **resource group** (`resource_group`).
- Terraform and providers per [`versions.tf`](versions.tf).
- **`azurerm`** and **`azuread`** authentication (e.g. `az login`) when resolving principals by name.
- Permissions to create Key Vaults and assign access policies or RBAC as appropriate for your subscription.

**Behaviour notes (as implemented)**

- **`enable_rbac_authorization`**: when **`true`**, you must **not** combine RBAC with legacy access policies entries in a conflicting way. A **`lifecycle.precondition`** fails if `access_policies` is non-empty while RBAC is enabled (`has_access_policies` in [`main.tf`](main.tf)).
- **`access_policies`**: each entry should have a **unique `name`** (used as `for_each` keys in data sources). Set **`object_id`** to skip lookup; otherwise set **`type`** to `user`, `group`, or `service_principal` and **`name`** to UPN, group display name, or service principal display name respectively.
- **`tags_from_rg`**: when `true`, merge tags from the resource group data source with `tags`.

## Basic usage

```hcl
module "key_vault" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-kv?ref=azure-kv-v1.5.1"

  name                        = "kvexample001"
  resource_group              = "example-rg"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"
  enable_rbac_authorization   = false

  access_policies = [
    {
      name                = "bootstrap-admin"
      type                = ""
      object_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      key_permissions     = ["Get", "List"]
      secret_permissions  = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = []
    }
  ]

  tags_from_rg = false
  tags         = { workload = "example" }
}
```

Replace GUIDs and names with real values. With **`enable_rbac_authorization = true`**, use **`access_policies = []`** and manage access via Azure RBAC outside this module.

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Data sources, locals, Key Vault |
| `variables.tf` | Inputs |
| `outputs.tf` | Key Vault resource ID |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
