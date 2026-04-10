# `azure-flexible-server-postgresql`

## Overview

Terraform module that provisions an **Azure Database for PostgreSQL Flexible Server** (`azurerm_postgresql_flexible_server`) plus optional **server parameters**, **firewall rules**, and a **Key Vault secret** workflow related to the administrator password.

**Typical dependencies**

- An existing **resource group** (`resource_group`).
- A **Key Vault** and secret name for the admin password: the module creates `azurerm_key_vault_secret.password_create` from `random_password` (with `lifecycle.ignore_changes` on the secret `value` after the first write) and reads `data.azurerm_key_vault_secret.administrator_password`, but the current `coalesce(var.administrator_password_key_vault_secret_name, data.azurerm_key_vault_secret.administrator_password[0].value)` logic in `main.tf` prefers the configured secret **name** whenever it is set rather than the looked-up secret **value**. In other words, the current implementation does **not** reliably set `administrator_password` from the Key Vault secret value; see `main.tf` before relying on this flow. You may need an initial `terraform apply` focused on the Key Vault secret before the flexible server can be created successfully, depending on your pipeline and secret state.
- For **private access** (`public_network_access_enabled = false`): resolve a **virtual network** (by name and resource group, or by tags through `azurerm_resources`), supply a **delegated subnet** (`subnet_name`) and **private DNS zone** (`dns_private_zone_name`) as required by Azure for Flexible Server.
- For **public access** (`public_network_access_enabled = true`): configure **`firewall_rule`** entries instead of relying on the private subnet path.

**Lookup behaviour (honest notes)**

- **Key Vault**: resolved with `azurerm_resources` using `key_vault.name` + `key_vault.resource_group_name`, or `key_vault.tags` when the tags map is non-empty.
- **VNet**: same pattern with `vnet.name` / `vnet.resource_group_name` or `vnet.tags`. The `data.azurerm_resources.vnet_from_name` data source is always declared; you must supply identifiers that match a real VNet in your subscription where the data source is evaluated (even for some public-only flows), or plan/apply may fail.
- **`postgresql_flexible_server`**: the variable type marks `maintenance_window` and `authentication` as optional, but the root module passes them straight into fixed nested blocks—supply concrete objects in normal use.
- **Lifecycle**: `azurerm_postgresql_flexible_server` ignores changes to `version`, `create_mode`, `point_in_time_restore_time_in_utc`, `source_server_id`, and `zone` after create (see `main.tf`).

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
| `main.tf` | Flexible Server, configuration, firewall, random password, Key Vault secret |
| `data.tf` | Resource group, VNet/Key Vault lookups, subnet, private DNS zone, secret read |
| `variables.tf` | Inputs |
| `outputs.tf` | Exported values |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples, provider links, PITR notes |
| `_examples/basic` | Minimal wiring for `validate` |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated tables (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
