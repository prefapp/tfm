## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116.0 |


## Resources and datas

| Resource | Type |
|---------|------|
| [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | Resource |
| [azurerm_postgresql_flexible_server_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | Resource |
| random_password | Resource |
| [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | Resource |
| [azurerm_postgresql_flexible_server_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | Resource |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html) | Data |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | Data |
| [azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | Data |
| [azurerm_resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | Data |
| [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | Data |

## Inputs

| Name | Description | Type | Default | Required |
|------|------------|------|---------|:--------:|
| `resource_group` | Name of the resource group | `string` | N/A | ✅ |
| `subnet_name` | Name of the subnet | `string` | `null` | ❌ |
| `dns_private_zone_name` | Name of the private DNS zone | `string` | `null` | ❌ |
| `key_vault` | Key Vault configuration | `object({ name = optional(string), resource_group_name = optional(string) })` | `{}` | ❌ |
| `key_vault_tags` | Tags for the Key Vault | `map(any)` | `{}` | ❌ |
| `administrator_password_key_vault_secret_name` | Name of the administrator password secret in Key Vault | `string` | `null` | ❌ |
| `tags_from_rg` | If `true`, uses tags from the resource group | `bool` | `false` | ❌ |
| `tags` | Input tags if not using the resource group tags | `map(string)` | `{}` | ❌ |
| `vnet_tags` | Tags for the virtual network | `map(any)` | `{}` | ❌ |
| `postgresql_flexible_server` | PostgreSQL Flexible Server configuration | `object` | N/A | ✅ |
| `postgresql_flexible_server_configuration` | Additional configuration for the server | `map(object({ name = optional(string), value = optional(string) }))` | `{}` | ❌ |
| `vnet` | Virtual network configuration | `object({ name = optional(string), resource_group_name = optional(string) })` | `{}` | ❌ |
| `firewall_rule` | List of firewall rules to allow access to the PostgreSQL server | `list(object({ name = optional(string), start_ip_address = optional(string), end_ip_address = optional(string) }))` | `[]` | ❌ |


### Notes
You can create the `administrator_password_key_vault_secret_name` with the `random_password` resource or you can add it as a input. Also, if you create the password with this resource, you will need to do a `terraform apply` on the resource `azurerm_key_vault_secret.password_create` before create the postresql flexible server.

You can use `name` and `resource_group_name` in `vnet` and `key_vault` variables as inputs to get the `data.azurerm_resource` or you can use `tags` as a input (`vnet_tags` and `key_vault_tags`) to get the data.

If you set `public_network_access_enabled: true` you won't need the inputs `subnet_name` and `dns_private_zone_name`. You will need to add a list of IP's in `firewall_rule` to have access to the postresql flexible server instead.

When you set `create_mode` to `PointInTimeRestore` you will need to add the outputs `source_server_id` and `point_in_time_restore_time_in_utc`. Read more about the PITR in the next paragraph (`create_mode` is set to `default` by default).


## PITR creation explanation

When create_mode = "PointInTimeRestore", you need to provide:

  1. source_server_id: The resource ID of the original server from which to restore.

  2. point_in_time_restore_time_in_utc: The timestamp (UTC) to restore from.

PointInTimeRestore will do:

  1. **Creates a new server**: This does not modify the original server, it creates a new one with a different name instead.

  2. **Requieres a `source_server_id`**: The original server must have avaliable backups.

  3. **Must provide a restore timestamp**: `point_in_time_restore_time_in_utc` must be within the backup retention period.

  4. Once restored, you may want to change `create_mode` to `Default` to avoid reapplying the restore when running `terraform apply` again.

  5. If the original server is deleted, the PITR server remains unafected.

  6. If `point_in_time_restore_time_in_utc` is not within the retention period, the restore will fail.



## Get list of PiTRs backups

```yaml
az postgres flexible-server backup list --resource-group test-modulo --name mi-server
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="id"></a> [id](#output\_id) | The ID of the postgresql flexible server |

## Example Usage

```yaml
values:
  resource_group: "example-resource-group"
  tags_from_rg: true
  key_vault:
    tags:
     value: "tag1"
    #name: "key-vault-name"
    #resource_group_name: "key-vault-resource-group-name"
  vnet:
    tags:
      value: "tag1"
    #name: "example-vnet"
    #resource_group_name: "vnet-resource-group-name"
  subnet_name: "example-subnet"
  dns_private_zone_name: "dns.private.zone.example.com"
  administrator_password_key_vault_secret_name: "flexible-server-secret-example-test"
  postgresql_flexible_server:
    location: "westeurope"
    name: "example-flexible-server"
    version: "15"
    administrator_login: "psqladmin"
    public_network_access_enabled: false
    storage_mb: "65536"
    sku_name: "GP_Standard_D2ds_v5"
    maintenance_window:
      day_of_week: 6
      start_hour: 0
      start_minute: 0
    authentication:
      active_directory_auth_enabled: false
      password_auth_enabled: true
  postgresql_flexible_server_configuration:
    azure.extensions:
      name: "azure.extensions"
      value: "extension1,extension2"
    configuration1:
      name: "example-configuration"
      value: "TRUE"
```
