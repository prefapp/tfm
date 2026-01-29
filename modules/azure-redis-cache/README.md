<!-- BEGIN_TF_DOCS -->
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
  private_endpoint:
    name: "pv_exmaple_redis-nic"
    custom_network_interface_name: "pv_example_redis-nic"
    private_service_connection:
      is_manual_connection: false
```

### Premium configuration example
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_redis_cache.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |
| [azurerm_private_dns_zone.dns_private_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resources.vnet_from_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_resources.vnet_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_private_zone_name"></a> [dns\_private\_zone\_name](#input\_dns\_private\_zone\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | n/a | <pre>object({<br/>    name                          = string<br/>    dns_zone_group_name           = optional(string, "default")<br/>    custom_network_interface_name = string<br/>    private_service_connection = optional(object({<br/>      is_manual_connection = bool<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_redis"></a> [redis](#input\_redis) | n/a | <pre>object({<br/>    name                          = string<br/>    location                      = string<br/>    capacity                      = number<br/>    family                        = string<br/>    sku_name                      = string<br/>    non_ssl_port_enabled          = optional(bool)<br/>    minimum_tls_version           = optional(string)<br/>    redis_version                 = optional(number)<br/>    public_network_access_enabled = optional(bool)<br/>    zones                         = optional(list(string))<br/>    subnet_id                     = optional(string)<br/>    patch_schedule = optional(object({<br/>      day_of_week    = optional(string)<br/>      start_hour_utc = optional(number)<br/>    }))<br/>    redis_configuration = optional(object({<br/>      aof_backup_enabled                      = optional(bool)<br/>      aof_storage_connection_string_0         = optional(string)<br/>      aof_storage_connection_string_1         = optional(string)<br/>      authentication_enabled                  = optional(bool)<br/>      active_directory_authentication_enabled = optional(bool)<br/>      maxmemory_reserved                      = optional(number)<br/>      maxmemory_delta                         = optional(number)<br/>      maxmemory_policy                        = optional(string)<br/>      maxfragmentationmemory_reserved         = optional(number)<br/>      rdb_backup_enabled                      = optional(bool)<br/>      rdb_backup_frequency                    = optional(number)<br/>      rdb_backup_max_snapshot_count           = optional(number)<br/>      rdb_storage_connection_string           = optional(string)<br/>      storage_account_subscription_id         = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | n/a | `bool` | `false` | no |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | n/a | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | n/a |
| <a name="output_redis_id"></a> [redis\_id](#output\_redis\_id) | n/a |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/basic) - Basic Redis Cache instance with virtual network integration and private endpoint.

## Resources and support

- [Official Azure Redis Cache documentation](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/)
- [Terraform reference for azurerm\_redis\_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
- [Terraform reference for azurerm\_private\_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->