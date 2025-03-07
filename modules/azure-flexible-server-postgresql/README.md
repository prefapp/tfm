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
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html) | Data |
| [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | Resource |
| [azurerm_postgresql_flexible_server_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | Resource |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | Data |
| [azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | Data |
| [azurerm_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | Data |
| [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | Data |

## Inputs

| Nombre | Descripción | Tipo | Default | Requerido |
|--------|------------|------|---------|:--------:|
| `resource_group` | Name of the resource group | `string` | N/A | ✅ |
| `tags_from_rg` | Setting it to true, gives the tags from your resource group | `bool` | `false` | ❌ |
| `tags` | Input tags if you dont want the resource group ones | `map(string)` | `{ "name": "value" }` | ❌ |
| `subnet` | Subnet config | `object` | N/A | ✅ |
| `dns_private_zone` | DNS private zone config | `object` | N/A | ✅ |
| `postgresql_flexible_server` |  PostgreSQL Flexible config | `object` | N/A | ✅ |
| `postgresql_flexible_server_configuration` | Aditional config for the server | `map(object)` | `{}` | ❌ |
| `key_vault` | Key Vault config | `object` | N/A | ❌ |
| `administrator_password_key_vault_secret_name` | Name of the secret password from key vault | `string` | null | ❌ |
| `admin_password` | Administrator password (sensitive) | `string` | `null` | ❌ |

### Note
If you add a **admin_pasword** as a input, you won't get the **administrator_password_key_vault_secret_name**.

## PITR creation explanation

The creation of a server from a PITR will create a new server. If the source is different and is deleted, the new server will not be affected, however, you will have to change the `server_creation.mode` to `Default` after its creation so that it is not tried to restore again and thus be able to apply a `terraform plan` or` terraform apply` without trying to restore again.

## Outputs

| Name | Description |
|------|-------------|
| <a name="id"></a> [id](#output\_id) | The ID of the postgresql flexible server |

## Example Usage

```yaml
resource_group: "your-resource-group"
tags_from_rg: true
subnet:
  name: "subnet_name"
dns_private_zone:
  name: "dns-private-name"
key_vault:
  name: "key-vault-name"
  resource_group_name: "key-vault-resource-group"
administrator_password_key_vault_secret_name: "your-secret-password"
postgresql_flexible_server:
  location: "eastus"
  name: "flexible-server-name"
  version: "15"
  administrator_login: "admin1"
  zone: "2"
  storage_mb: "65536"
  sku_name: "GP_Standar"
  maintenance_window:
    day_of_week: 6
    start_hour: 0
    start_minute: 0
  authentication:
    active_directory_auth_enabled: false
    password_auth_enabled: true
postgresql_flexible_server_configuration:
  azure.config1:
    name: "azure.config1"
    value: "Config1"
  azure.config2:
    name: "azure.config2"
    value: "Config2"
```
