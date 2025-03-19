## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.23.0 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.23.0 |


## Resources and datas

| Resource | Type |
|---------|------|
| [azurerm_redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | Resource |
| [azurerm_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | Resource |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group.html) | Data |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | Data |
| [azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | Data |
| [azurerm_resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | Data |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `resource_group` | Name of the resource group | `string` | N/A | ✅ |
| `tags_from_rg` | If `true`, uses tags from the resource group | `bool` | `false` | ❌ |
| `tags` | Input tags if not using the resource group tags | `map(string)` | `{}` | ❌ |
| `vnet` | Virtual network configuration | `object({ name = optional(string), resource_group_name = optional(string), tags = optional(map(string)) })` | `{}` | ❌ |
| `subnet_name` | Name of the subnet | `string` | N/A | ✅ |
| `dns_private_zone_name` | Name of the private DNS zone | `string` | N/A | ✅ |
| `redis` | Redis cache configuration | `object({ name = string, location = string, capacity = number, family = string, sku_name = string, non_ssl_port_enabled = optional(bool), minimum_tls_version = optional(string), redis_version = optional(number), public_network_access_enabled = optional(bool), zones = optional(list(string)), subnet_id = optional(string), patch_schedule = optional(object({ day_of_week = optional(string), start_hour_utc = optional(number) })), redis_configuration = optional(object({ aof_backup_enabled = optional(bool), aof_storage_connection_string_0 = optional(string), aof_storage_connection_string_1 = optional(string), authentication_enabled = optional(bool), active_directory_authentication_enabled = optional(bool), maxmemory_reserved = optional(number), maxmemory_delta = optional(number), maxmemory_policy = optional(string), maxfragmentationmemory_reserved = optional(number), rdb_backup_enabled = optional(bool), rdb_backup_frequency = optional(number), rdb_backup_max_snapshot_count = optional(number), rdb_storage_connection_string = optional(string), storage_account_subscription_id = optional(string) })) })` | N/A | ✅ |
| `private_endpoint` | Private endpoint configuration | `object({ name = string, custom_network_interface_name = string, private_service_connection = optional(object({ is_manual_connection = bool })) })` | N/A | ✅ |



### Notes

1. The configuration block `redis_configuration` is only available when `sku_name = "Premium"` and `family = "P"`.

2. You can get data from `name` and `resource_group_name` or with `tags`.

2. When you set `sku_name = "Premium"` and `family = "P"`, you won't be able to create the resource `azurerm_private_endpoint.this`.

3. Creating an Azure Redis cache resource takes approximately 25 minutes.


## Outputs

| Name | Description |
|------|-------------|
| <a name="redis_id"></a> [redis_id](#output\redis_id) | The ID of the redis cache |
| <a name="private_endpoint_id"></a> [private_endpoint_id](#output\private_endpoint_id) | The ID of the private endpoint |

## Example Usage

### Basic configuration example.

```yaml
values:
  resource_group: "example-rg"
  vnet:
    tags:
      value: "tag1"
    #name: "example-vnet-name"
    #resource_group_name: "example-vnet"
  subnet_name: "example-subnet"
  dns_private_zone_name: "example.dns.zone"
  redis:
    location: "westeurope"
    name: "redis-test"
    capacity: 1
    family: "C"
    sku_name: "Standard"
    non_ssl_port_enabled: true
    public_network_access_enabled: false
    minimum_tls_version: "1.2"
    redis_version: 6
    patch_schedule:
      day_of_week: "Monday"
      start_hour_utc: 0
  private_endpoint:
    name: "pv_exmaple_redis-nic"
    custom_network_interface_name: "pv_example_redis-nic"
    private_service_connection:
      is_manual_connection: false

```

### Premium configuration example.

```yaml
values:
  resource_group: "example-rg"
  vnet:
    tags:
      value: "tag1"
    #name: "example-vnet-name"
    #resource_group_name: "example-vnet"
  subnet_name: "example-subnet"
  dns_private_zone_name: "example.dns.zone"
  redis:
    location: "westeurope"
    name: "redis-test"
    capacity: 1
    family: "P"
    sku_name: "Premium"
    non_ssl_port_enabled: true
    public_network_access_enabled: false
    minimum_tls_version: "1.2"
    redis_version: 6
    patch_schedule:
      day_of_week: "Monday"
      start_hour_utc: 0
    redis_configuration:
      aof_backup_enabled: true
      aof_storage_connection_string_0: "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.nc-cruks-storage-account.primary_blob_endpoint};AccountName=${azurerm_storage_account.mystorageaccount.name};AccountKey=${azurerm_storage_account.mystorageaccount.primary_access_key}"
      aof_storage_connection_string_1: "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.mystorageaccount.primary_blob_endpoint};AccountName=${azurerm_storage_account.mystorageaccount.name};AccountKey=${azurerm_storage_account.mystorageaccount.secondary_access_key}"
      authentication_enabled: true
      active_directory_authentication_enabled: false
      maxmemory_reserved: 200
      maxmemory_delta: 200
      maxmemory_policy: "volatile-lru"
      maxfragmentationmemory_reserved: 200
      rdb_backup_enabled: false
      storage_account_subscription_id: "xxxxxxx-xxxxx-xxxxx-xxxxxx"
  private_endpoint:
    name: "pv_example_redis-nic"
    custom_network_interface_name: "pv_example_redis-nic"
    private_service_connection:
      is_manual_connection: false

```
