<!-- BEGIN_TF_DOCS -->
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
| `docs/header.md` | Overview (terraform-docs header) |
| `docs/footer.md` | Examples and links |
| `_examples/basic` | Minimal example |
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
| [azurerm_key_vault_secret.password_create](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_key_vault_secret.administrator_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_private_dns_zone.dns_private_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resources.key_vault_from_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_resources.key_vault_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_resources.vnet_from_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_resources.vnet_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_password_key_vault_secret_name"></a> [administrator\_password\_key\_vault\_secret\_name](#input\_administrator\_password\_key\_vault\_secret\_name) | Required name of the Key Vault secret for the PostgreSQL administrator password (read by `data.azurerm_key_vault_secret`, written by `azurerm_key_vault_secret.password_create`). | `string` | n/a | yes |
| <a name="input_dns_private_zone_name"></a> [dns\_private\_zone\_name](#input\_dns\_private\_zone\_name) | Private DNS zone name for the flexible server when using private networking. | `string` | `null` | no |
| <a name="input_firewall_rule"></a> [firewall\_rule](#input\_firewall\_rule) | Firewall rules for public access; entries with `name == null` are skipped. | <pre>list(object({<br/>    name             = optional(string)<br/>    start_ip_address = optional(string)<br/>    end_ip_address   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Key Vault lookup by `name` + `resource_group_name`, or by `tags` via `azurerm_resources` when the tags map is non-empty. | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Length of the password generated by `random_password.password` before storing it in Key Vault. | `number` | `20` | no |
| <a name="input_postgresql_flexible_server"></a> [postgresql\_flexible\_server](#input\_postgresql\_flexible\_server) | Flexible Server settings. Nested `maintenance_window` and `authentication` blocks are always rendered; supply them in normal use. | <pre>object({<br/>    name                              = string<br/>    location                          = string<br/>    version                           = optional(number)<br/>    public_network_access_enabled     = optional(bool)<br/>    administrator_login               = optional(string)<br/>    zone                              = optional(string)<br/>    storage_tier                      = optional(string)<br/>    storage_mb                        = optional(number)<br/>    sku_name                          = optional(string)<br/>    replication_role                  = optional(string)<br/>    create_mode                       = optional(string)<br/>    source_server_id                  = optional(string)<br/>    point_in_time_restore_time_in_utc = optional(string)<br/>    backup_retention_days             = optional(number)<br/>    maintenance_window = optional(object({<br/>      day_of_week  = number<br/>      start_hour   = number<br/>      start_minute = number<br/>    }))<br/>    authentication = optional(object({<br/>      active_directory_auth_enabled = bool<br/>      password_auth_enabled         = bool<br/>      tenant_id                     = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_postgresql_flexible_server_configuration"></a> [postgresql\_flexible\_server\_configuration](#input\_postgresql\_flexible\_server\_configuration) | Map of PostgreSQL server configuration parameters (`azurerm_postgresql_flexible_server_configuration`). | <pre>map(object({<br/>    name  = optional(string)<br/>    value = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing resource group that hosts the server and lookup resources. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnet name for private access; used when `public_network_access_enabled` is false. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the flexible server. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | When true, merge the resource group tags with `tags` (latter wins on key conflicts). | `bool` | `false` | no |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | Virtual network: use `name` and `resource_group_name`, and/or `tags` for `azurerm_resources` lookup. | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_administrator_password_key_vault_secret_id"></a> [administrator\_password\_key\_vault\_secret\_id](#output\_administrator\_password\_key\_vault\_secret\_id) | Resource ID of the Key Vault secret for the administrator password. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | FQDN of the server (hostname for client connection strings). |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the PostgreSQL Flexible Server. |
| <a name="output_name"></a> [name](#output\_name) | Name of the PostgreSQL Flexible Server. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/basic) — Minimal wiring for `init` / `validate`; set credentials and names before apply, and pass `postgresql_flexible_server_configuration` (use `{}` if none — see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-flexible-server-postgresql/_examples/comprehensive) — Illustrative `values.reference.yaml` for wrappers or pipelines (placeholders only — see folder README).

## Resources

**azurerm** links below use **4.35.0**, aligned with `versions.tf`. **random** links use `/latest` (implicit dependency via `random_password`; no separate `required_providers` entry). Pinned versions for your workspace appear in the **Providers** table after regenerating this README with `terraform-docs .`, as described in [README.md generation](https://github.com/prefapp/tfm/blob/main/CONTRIBUTING.md#5-readmemd-generation).

- **Azure Database for PostgreSQL — Flexible Server**: [https://learn.microsoft.com/azure/postgresql/flexible-server/overview](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
- **azurerm\_postgresql\_flexible\_server**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server)
- **azurerm\_postgresql\_flexible\_server\_configuration**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server\_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server\_configuration)
- **azurerm\_postgresql\_flexible\_server\_firewall\_rule**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server\_firewall\_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/postgresql_flexible_server\_firewall\_rule)
- **azurerm\_key\_vault\_secret**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/key_vault_secret)
- **azurerm\_resources** (data source): [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/data-sources/resources)
- **random\_password**: [https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0)
- **Terraform Random provider**: [https://registry.terraform.io/providers/hashicorp/random/latest](https://registry.terraform.io/providers/hashicorp/random/latest)

## Point-in-time restore

For `create_mode = "PointInTimeRestore"`, provide `source_server_id` and `point_in_time_restore_time_in_utc` within retention. Example CLI:

```bash
az postgres flexible-server backup list --resource-group my-resource-group --name my-server-name
```

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
