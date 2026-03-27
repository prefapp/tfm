# Azure Redis Cache Terraform Module

## Overview

This Terraform module allows you to create and manage an Azure Redis Cache instance, supporting both Standard and Premium SKUs, private endpoints, and advanced configuration options.

## Main features
- Create a Redis Cache with custom name, location, and resource group.
- Support for Standard and Premium SKUs, including advanced configuration for Premium.
- Private endpoint creation and DNS integration.
- Flexible tagging and VNet/subnet selection.
- Realistic configuration examples for both Standard and Premium.

## Complete usage example

### Basic configuration example

```yaml
resource_group: example-rg

vnet:
  name: example-vnet
  resource_group_name: example-rg

subnet_name: redis-subnet
dns_private_zone_name: privatelink.redis.cache.windows.net

redis:
  name: example-redis
  location: westeurope
  capacity: 1
  family: C
  sku_name: Standard
  redis_version: 6
  minimum_tls_version: "1.2"
  public_network_access_enabled: false
  redis_configuration:
    rdb_backup_enabled: false
    authentication_enabled: true
    maxmemory_policy: allkeys-lru

private_endpoint:
  name: example-redis-pe
  custom_network_interface_name: example-redis-pe-nic

tags:
  environment: dev
  application: example
```

### Premium configuration example

```yaml
resource_group: example-rg

vnet:
  tags:
    value: tag1
  #name: example-vnet-name
  #resource_group_name: example-vnet

subnet_name: example-subnet
dns_private_zone_name: example.dns.zone

redis:
  location: westeurope
  name: redis-test
  capacity: 1
  family: P
  sku_name: Premium
  non_ssl_port_enabled: true
  public_network_access_enabled: false
  minimum_tls_version: "1.2"
  redis_version: 6
  patch_schedule:
    day_of_week: Monday
    start_hour_utc: 0
  redis_configuration:
    aof_backup_enabled: true
    aof_storage_connection_string_0: "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.nc-cruks-storage-account.primary_blob_endpoint};AccountName=${azurerm_storage_account.mystorageaccount.name};AccountKey=${azurerm_storage_account.mystorageaccount.primary_access_key}"
    aof_storage_connection_string_1: "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.mystorageaccount.primary_blob_endpoint};AccountName=${azurerm_storage_account.mystorageaccount.name};AccountKey=${azurerm_storage_account.mystorageaccount.secondary_access_key}"
    authentication_enabled: true
    active_directory_authentication_enabled: false
    maxmemory_reserved: 200
    maxmemory_delta: 200
    maxmemory_policy: volatile-lru
    maxfragmentationmemory_reserved: 200
    rdb_backup_enabled: false
    storage_account_subscription_id: "xxxxxxx-xxxxx-xxxxx-xxxxxx"

private_endpoint:
  name: pv_example_redis-nic
  custom_network_interface_name: pv_example_redis-nic
  private_service_connection:
    is_manual_connection: false
```

## Notes
- The `redis_configuration` block is only available for Premium SKUs (`sku_name = "Premium"` and `family = "P"`).
- You can select the VNet by name/resource group or by tags.
- If you provide `subnet_id`, the private endpoint will not be created automatically.
- Creating an Azure Redis Cache resource can take up to 25 minutes.

## File structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```