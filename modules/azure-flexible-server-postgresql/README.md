## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.35.0 |

To create the postgresql flexible server you must have:
 - A resource group.
 - A virtual network.
 - A keyvault to store/read a secret with the PostgreSQL admin pass.
 - The dns and the subnet will be necesary when `public_network_access_enabled=false`.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.35.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

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
| <a name="input_administrator_password_key_vault_secret_name"></a> [administrator\_password\_key\_vault\_secret\_name](#input\_administrator\_password\_key\_vault\_secret\_name) | Name of the Key Vault secret containing the administrator password | `string` | `null` | no |
| <a name="input_dns_private_zone_name"></a> [dns\_private\_zone\_name](#input\_dns\_private\_zone\_name) | Name of the private DNS zone for the PostgreSQL server | `string` | `null` | no |
| <a name="input_firewall_rule"></a> [firewall\_rule](#input\_firewall\_rule) | List of firewall rules to allow access to the server | <pre>list(object({<br/>    name             = optional(string)<br/>    start_ip_address = optional(string)<br/>    end_ip_address   = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Key Vault configuration object (name, resource group, tags) | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Length of the generated administrator password | `number` | `20` | no |
| <a name="input_postgresql_flexible_server"></a> [postgresql\_flexible\_server](#input\_postgresql\_flexible\_server) | Configuration object for the PostgreSQL Flexible Server | <pre>object({<br/>    name                              = string<br/>    location                          = string<br/>    version                           = optional(number)<br/>    public_network_access_enabled     = optional(bool)<br/>    administrator_login               = optional(string)<br/>    zone                              = optional(string)<br/>    storage_tier                      = optional(string)<br/>    storage_mb                        = optional(number)<br/>    sku_name                          = optional(string)<br/>    replication_role                  = optional(string)<br/>    create_mode                       = optional(string)<br/>    source_server_id                  = optional(string)<br/>    point_in_time_restore_time_in_utc = optional(string)<br/>    backup_retention_days             = optional(number)<br/>    maintenance_window = optional(object({<br/>      day_of_week  = number<br/>      start_hour   = number<br/>      start_minute = number<br/>    }))<br/>    authentication = optional(object({<br/>      active_directory_auth_enabled = bool<br/>      password_auth_enabled         = bool<br/>      tenant_id                     = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_postgresql_flexible_server_configuration"></a> [postgresql\_flexible\_server\_configuration](#input\_postgresql\_flexible\_server\_configuration) | Map of configuration parameters for the PostgreSQL Flexible Server | <pre>map(object({<br/>    name  = optional(string)<br/>    value = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the resource group where resources will be created | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet for the PostgreSQL Flexible Server | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Map of tags to assign to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input_tags_from_rg) | Whether to inherit tags from the resource group | `bool` | `false` | no |
| <a name="input_vnet"></a> [vnet](#input_vnet) | Virtual Network configuration object (name, resource group, tags) | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |

### Notes
You can create the `administrator_password_key_vault_secret_name` with the `random_password` resource or you can add it as a input. Also, if you create the password with this resource, you will need to do a `terraform apply` on the resource `azurerm_key_vault_secret.password_create` before create the postresql flexible server.

You can use `name` and `resource_group_name` in `vnet` and `key_vault` variables as inputs to get the `data.azurerm_resource` or you can use `tags` as a input (`vnet.tags` and `key_vault.tags`) to get the data.

If you set `public_network_access_enabled: true` you won't need the inputs `subnet_name` and `dns_private_zone_name`. You will need to add a list of IP's in `firewall_rule` to have access to the postresql flexible server instead.

When you set `create_mode` to `PointInTimeRestore` you will need to add the outputs `source_server_id` and `point_in_time_restore_time_in_utc`. Read more about the PITR in the next paragraph (`create_mode` is set to `default` by default).


## PITR creation explanation

When `create_mode = PointInTimeRestore`, you need to provide:

  1. source_server_id: The resource ID of the original server from which to restore.

  2. point_in_time_restore_time_in_utc: The timestamp (UTC) to restore from.

PointInTimeRestore will do:

  1. **Creates a new server**: This does not modify the original server, it creates a new one with a different name instead.

  2. **Requieres a `source_server_id`**: The original server must have avaliable backups.

  3. **Must provide a restore timestamp**: `point_in_time_restore_time_in_utc` must be within the backup retention period.

  4. Once restored, you may want to change `create_mode` to `Default` to avoid reapplying the restore when running `terraform apply` again.

  5. If the original server is deleted, the PITR server remains unafected.

  6. If `point_in_time_restore_time_in_utc` is not within the retention period, the restore will fail.

  7. The format of `point_in_time_restore_time_in_utc` must be `Year-Month-DayTHour:Min:sec+00:00` or the restore will fail, for example `2025-03-14T08:26:31Z`(https://en.wikipedia.org/wiki/ISO_8601).

## Get list of PiTRs backups

```yaml
az postgres flexible-server backup list --resource-group my-resource-group --name my-server-name
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
  password_lenght: 10
  postgresql_flexible_server:
    location: "westeurope"
    name: "example-flexible-server"
    version: "15"
    administrator_login: "psqladmin"
    public_network_access_enabled: false
    storage_mb: "65536"
    sku_name: "GP_Standard_D2ds_v5"
    backup_retention_days: 30
    #create_mode: "PointInTimeRestore"
    #source_server_id: "/subscriptions/xxxxxx-xxxx-xxxx-xxxxxx/resourceGroups/example-resource-group/providers/Microsoft.DBforPostgreSQL/flexibleServers/example-flexible-server"
    #point_in_time_restore_time_in_utc: "2025-02-21T09:35:43Z"
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
