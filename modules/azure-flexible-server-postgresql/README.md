<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.68.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.password_create](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret) | resource |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |
| [azurerm_key_vault_secret.administrator_password](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/key_vault_secret) | data source |
| [azurerm_private_dns_zone.dns_private_zone](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resource_group) | data source |
| [azurerm_resources.key_vault_from_name](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources) | data source |
| [azurerm_resources.key_vault_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources) | data source |
| [azurerm_resources.vnet_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_password_key_vault_secret_name"></a> [administrator\_password\_key\_vault\_secret\_name](#input\_administrator\_password\_key\_vault\_secret\_name) | Secret name in Key Vault for the server admin password. The module reads it via `data.azurerm_key_vault_secret` and writes an initial value from `random_password` with `azurerm_key_vault_secret.password_create` (value changes ignored after first set). | `string` | `null` | no |
| <a name="input_dns_private_zone_name"></a> [dns\_private\_zone\_name](#input\_dns\_private\_zone\_name) | Private DNS zone name linked to the flexible server when using private networking. | `string` | `null` | no |
| <a name="input_firewall_rule"></a> [firewall\_rule](#input\_firewall\_rule) | Firewall rules when public network access is enabled; entries with `name == null` are skipped. | <pre>list(object({<br/>    name             = optional(string)<br/>    start_ip_address = optional(string)<br/>    end_ip_address   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Locate the Key Vault: use `name` + `resource_group_name` together (queried via `azurerm_resources` only when both are set), or use non-empty `tags` as `required_tags`. When both are provided, the name-based match wins for `local.key_vault_id`. Tag lookup must resolve to exactly one vault (`resources[0]`). | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Length of the random password generated by `random_password.password` before it is written to Key Vault. | `number` | `20` | no |
| <a name="input_postgresql_flexible_server"></a> [postgresql\_flexible\_server](#input\_postgresql\_flexible\_server) | Flexible Server settings. The resource always renders `maintenance_window` and `authentication` nested blocks from this object; in practice you should supply both objects even though the type marks them optional, or the plan can fail on null attributes.<br/>`lifecycle.ignore_changes` ignores `version`, `create_mode`, `point_in_time_restore_time_in_utc`, `source_server_id`, and `zone` after creation. | <pre>object({<br/>    name                              = string<br/>    location                          = string<br/>    version                           = optional(number)<br/>    public_network_access_enabled     = optional(bool)<br/>    administrator_login               = optional(string)<br/>    zone                              = optional(string)<br/>    storage_tier                      = optional(string)<br/>    storage_mb                        = optional(number)<br/>    sku_name                          = optional(string)<br/>    replication_role                  = optional(string)<br/>    create_mode                       = optional(string)<br/>    source_server_id                  = optional(string)<br/>    point_in_time_restore_time_in_utc = optional(string)<br/>    backup_retention_days             = optional(number)<br/>    maintenance_window = optional(object({<br/>      day_of_week  = number<br/>      start_hour   = number<br/>      start_minute = number<br/>    }))<br/>    authentication = optional(object({<br/>      active_directory_auth_enabled = bool<br/>      password_auth_enabled         = bool<br/>      tenant_id                     = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_postgresql_flexible_server_configuration"></a> [postgresql\_flexible\_server\_configuration](#input\_postgresql\_flexible\_server\_configuration) | Server parameters as a map; each entry sets `azurerm_postgresql_flexible_server_configuration` (typically use stable keys and set `name`/`value` per entry). | <pre>map(object({<br/>    name  = optional(string)<br/>    value = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing resource group referenced by `data.azurerm_resource_group.resource_group` (server and lookups). | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnet delegated for PostgreSQL when `public_network_access_enabled` is false; required together with VNet resolution and private DNS for private access. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the flexible server. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Merge tags from the resource group with `tags` (module tags win on duplicate keys). | `bool` | `false` | no |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | Virtual network lookup by `name` + `resource_group_name`, or by `tags` via `azurerm_resources` when private connectivity is used. | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Azure resource ID of the PostgreSQL Flexible Server. |

## Examples

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/basic)
- [Comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/comprehensive)

## Provider documentation (aligned with `versions.tf`)

- [azurerm\_postgresql\_flexible\_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server)
- [azurerm\_postgresql\_flexible\_server\_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server\_configuration)
- [azurerm\_postgresql\_flexible\_server\_firewall\_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server\_firewall\_rule)
- [azurerm\_key\_vault\_secret](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret)
- [azurerm\_resources](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources)
- [azurerm\_key\_vault\_secret (data)](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/key_vault_secret)
- [random\_password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password)

## Point-in-time restore (`create_mode = "PointInTimeRestore"`)

When restoring to a new server:

1. Provide `source_server_id` (resource ID of the source flexible server) and `point_in_time_restore_time_in_utc` within the backup retention window.
2. Azure creates a **new** server; the source server is not modified.
3. After a successful restore, consider moving `create_mode` back to default/`Default` behaviour so later applies do not re-apply restore semantics (the module ignores several of these attributes after create, but operator workflow should still follow Azure guidance).
4. Timestamp format must be valid ISO 8601 UTC (for example `2025-03-14T08:26:31Z`).

List backups (Azure CLI):

```bash
az postgres flexible-server backup list --resource-group my-resource-group --name my-server-name
```

## Issues

[https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->