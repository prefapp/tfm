# `azure-flexible-server-postgresql`

## Overview

Terraform module that provisions an **Azure Database for PostgreSQL Flexible Server** (`azurerm_postgresql_flexible_server`) plus optional **server parameters**, **firewall rules**, and a **Key Vault secret** workflow related to the administrator password.

**Typical dependencies**

- An existing **resource group** (`resource_group`).
- A **Key Vault** and secret name for the admin password: the vault is resolved once in `local.key_vault_id` (name + resource group **or** tags; name wins if both are configured). The module writes the generated password with `azurerm_key_vault_secret.password_create` (`lifecycle.ignore_changes` on `value`) and sets the server `administrator_password` from `data.azurerm_key_vault_secret.administrator_password`. `depends_on` orders secret creation before the flexible server in the same apply.
- For **private access** (`public_network_access_enabled = false`): resolve a **virtual network** (by name and resource group, or by tags through `azurerm_resources`), supply a **delegated subnet** (`subnet_name`) and **private DNS zone** (`dns_private_zone_name`) as required by Azure for Flexible Server.
- For **public access** (`public_network_access_enabled = true`): configure **`firewall_rule`** entries instead of relying on the private subnet path.

**Lookup behaviour (honest notes)**

- **Key Vault**: `data.azurerm_resources.key_vault_from_name` runs only when both `name` and `resource_group_name` are set; otherwise `data.azurerm_resources.key_vault_from_tags` runs when `tags` is non-empty. `local.key_vault_id` is `coalesce(name-lookup, tags-lookup)`. If tag search matches several vaults, Azure returns multiple resources and this module uses the first (`resources[0]`)—ensure tags are selective.
- **VNet**: use `vnet.name` / `vnet.resource_group_name` directly, or resolve via `vnet.tags` through `data.azurerm_resources.vnet_from_tags` (no separate name-only `azurerm_resources` query for VNet).
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
