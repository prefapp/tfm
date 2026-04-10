# `azure-flexible-server-postgresql`

## Overview

Terraform module that provisions an **Azure Database for PostgreSQL Flexible Server** (`azurerm_postgresql_flexible_server`), optional **server parameters**, **firewall rules**, and a **Key Vault** workflow around the administrator password (`random_password` + `azurerm_key_vault_secret` + `data.azurerm_key_vault_secret`).

**Typical dependencies**

- Existing **resource group** (`resource_group`).
- **Key Vault** discoverable by `key_vault.name` + `key_vault.resource_group_name`, or by `key_vault.tags` via `azurerm_resources`.
- **Virtual network** identified by `vnet` (name + resource group and/or tags) when using private access.
- With **`public_network_access_enabled = false`**: delegated **subnet** and **private DNS zone** as required by Azure.

**Behaviour notes (as implemented in code)**

- **`administrator_password`** on the server is set with `coalesce(var.administrator_password_key_vault_secret_name, data.azurerm_key_vault_secret.administrator_password[0].value)`. When the secret **name** variable is non-null (normal case), the first argument wins, so the value passed to Azure is the **secret name string**, not the secret **value** from Key Vault. Confirm this matches your expectations before relying on it; otherwise adjust outside this documentation-only change set.
- **`maintenance_window`** and **`authentication`** are optional in the variable type but are always passed into fixed nested blocks; omitting them can cause plan errors—supply both objects in practice.
- **`lifecycle.ignore_changes`** on the flexible server includes `version`, `create_mode`, `point_in_time_restore_time_in_utc`, `source_server_id`, and `zone`.
- You may need a **first apply** that creates the Key Vault secret before the server can be created, depending on ordering and existing secret state.

## Basic usage

```hcl
module "postgresql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-flexible-server-postgresql?ref=azure-flexible-server-postgresql-v3.1.2"

  resource_group = "example-rg"

  key_vault = {
    name                = "example-kv"
    resource_group_name = "example-rg"
  }

  administrator_password_key_vault_secret_name = "pg-admin-password"

  vnet = {
    name                = "example-vnet"
    resource_group_name = "example-rg"
  }

  postgresql_flexible_server = {
    name                          = "example-pg"
    location                      = "westeurope"
    version                       = 15
    public_network_access_enabled = true
    administrator_login           = "psqladmin"
    storage_mb                    = 65536
    sku_name                      = "GP_Standard_D2ds_v5"
    backup_retention_days         = 30
    maintenance_window = {
      day_of_week  = 6
      start_hour   = 0
      start_minute = 0
    }
    authentication = {
      active_directory_auth_enabled = false
      password_auth_enabled         = true
    }
  }

  postgresql_flexible_server_configuration = {
    "azure.extensions" = {
      name  = "azure.extensions"
      value = "PGCRYPTO"
    }
  }

  firewall_rule = [
    {
      name             = "allow-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  ]

  tags = { example = "basic" }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Flexible Server, configurations, firewall, random password, Key Vault secret |
| `data.tf` | Resource group, lookups, subnet, private DNS, secret read |
| `variables.tf` | Inputs |
| `outputs.tf` | Outputs |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and links |
| `_examples/basic` | Minimal example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
