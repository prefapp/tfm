<!-- BEGIN_TF_DOCS -->
# Azure Cache for Redis Terraform module (`azure-redis-cache`)

## Overview

This module provisions **Azure Cache for Redis** (`azurerm_redis_cache`) together with a **private endpoint** and private **DNS zone** association. It looks up an existing **resource group**, resolves a **virtual network** by name (and resource group) or by **tags**, and reads a **subnet** and **private DNS zone** for connectivity.

The module includes **`moved`** blocks for state migration from older resource addresses.

## Key features

- **Networking**: Private endpoint to Redis (`redisCache` subresource) with DNS zone group.
- **VNet resolution**: `vnet.name` + `vnet.resource_group_name` and/or `vnet.tags` via `azurerm_resources`.
- **Tags**: Optional merge from the Redis resource group when `tags_from_rg = true`.
- **Premium options**: Optional `patch_schedule` and `redis_configuration` when `redis.family = "P"` (Premium).

## Notes

1. When **`redis.family` is `"P"`** (Premium), the module always opens a **`redis_configuration`** block on `azurerm_redis_cache` and reads **`redis.redis_configuration.*`**; supply a suitable **`redis_configuration`** object for Premium or plan/apply may fail.
2. You can locate the VNet by **`name` + `resource_group_name`** or by **`tags`** (see `data.tf`).
3. Setting **`redis.subnet_id`** on the cache is incompatible with using this module’s **private endpoint** pattern for the same workflow; see [Azure Redis VNet documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-premium-vnet).
4. Creating a Redis instance often takes **on the order of ~25 minutes**.
5. **`private_endpoint.private_service_connection`** must be provided (with **`is_manual_connection`**) — the module references it directly; omitting the block causes evaluation errors.

## Prerequisites

- Existing **resource group** for Redis and the private endpoint.
- **Virtual network** and **subnet** suitable for the private endpoint.
- **Private DNS zone** for Redis private link (commonly `privatelink.redis.cache.windows.net` in the DNS zone’s resource group).
- **azurerm** provider configured.

## Basic usage

```hcl
module "redis" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-redis-cache?ref=<version>"

  resource_group = "example-rg"
  subnet_name    = "example-subnet"
  dns_private_zone_name = "privatelink.redis.cache.windows.net"

  vnet = {
    name                = "example-vnet"
    resource_group_name = "example-network-rg"
  }

  redis = {
    name     = "redis-example"
    location = "westeurope"
    capacity = 1
    family   = "C"
    sku_name = "Standard"
  }

  private_endpoint = {
    name                          = "pe-redis"
    custom_network_interface_name = "pe-redis-nic"
    private_service_connection = {
      is_manual_connection = false
    }
  }
}
```

## File structure

```
.
├── CHANGELOG.md
├── data.tf
├── outputs.tf
├── private-endpoint.tf
├── redis-cache.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── comprehensive
├── README.md
└── .terraform-docs.yml
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

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/basic) — Minimal HCL module call (replace names, IDs, and network layout).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/comprehensive) — **`values.reference.yaml`**: Standard vs Premium-style input shapes (illustrative; wire via `yamldecode` or copy into your root module).

## Remote resources

- **Azure Cache for Redis**: [https://learn.microsoft.com/azure/azure-cache-for-redis/](https://learn.microsoft.com/azure/azure-cache-for-redis/)
- **Terraform `azurerm_redis_cache`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
- **Terraform `azurerm_private_endpoint`**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->