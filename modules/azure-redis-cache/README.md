<!-- BEGIN_TF_DOCS -->
# Azure Cache for Redis Terraform module (`azure-redis-cache`)

## Overview

This module provisions **Azure Cache for Redis** (`azurerm_redis_cache`) together with a **private endpoint** and private **DNS zone** association. It looks up an existing **resource group**, resolves a **virtual network** by name (and resource group) or by **tags**, and reads a **subnet** and **private DNS zone** for connectivity.

The module includes **`moved`** blocks for state migration from older resource addresses.

## Key features

- **Networking**: Zero, one or several private endpoints to Redis (`redisCache` subresource), each with its own DNS zone group, keyed by an arbitrary map key (`private_endpoints`).
- **VNet resolution**: per endpoint, by `vnet.name` + `vnet.resource_group_name` and/or `vnet.tags` via `azurerm_resources`.
- **Cross-subscription DNS zones**: per endpoint, either pass an already-resolved `private_dns_zone_id` (e.g. a Private DNS Zone in another subscription, obtained in claims via a `ref`), or let the module resolve it in the current subscription via `dns_private_zone_name`.
- **Tags**: Optional merge from the Redis resource group when `tags_from_rg = true`.
- **Premium options**: Optional `patch_schedule`; when `redis.family = "P"` (Premium), **`redis_configuration` must be set** in the current implementation (the resource block always dereferences `redis.redis_configuration.*`).

## Notes

1. When **`redis.family` is `"P"`** (Premium), the module always opens a **`redis_configuration`** block on `azurerm_redis_cache` and reads **`redis.redis_configuration.*`**; supply a suitable **`redis_configuration`** object for Premium or plan/apply may fail.
2. Each entry in **`private_endpoints`** resolves its own VNet, by **`name` + `resource_group_name`** or by **`tags`** (see `data.tf`).
3. Setting **`redis.subnet_id`** on the cache is incompatible with using this module’s **private endpoint** pattern for the same workflow; see [Azure Redis VNet documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-premium-vnet).
4. Creating a Redis instance often takes **on the order of ~25 minutes**.
5. **`private_endpoints.<key>.private_service_connection`** may be omitted; it defaults to **`{ is_manual_connection = false }`**. Set the block explicitly when you need a manual connection.
6. Each endpoint must set exactly one of **`private_dns_zone_id`** or **`dns_private_zone_name`**. When **`dns_private_zone_name`** is used, it is resolved with **`resource_group_name = coalesce(private_endpoints.<key>.dns_private_zone_resource_group, private_endpoints.<key>.vnet.resource_group_name, <resolved vnet resource group>)`**. When **`private_dns_zone_id`** is used instead, it is passed through as-is, allowing the zone to live in a different subscription (e.g. a value fetched in claims through a `ref`).
7. Migrating from the old single `private_endpoint` input to `private_endpoints` requires the first apply after upgrade to keep a `private_endpoints.default` entry present so Terraform can move state to the new keyed instance. If you intend to remove the private endpoint, first apply with `default` populated, then remove it in a second apply.

## Prerequisites

- Existing **resource group** for Redis and any private endpoints.
- **Virtual network** and **subnet** suitable for each private endpoint.
- A **Private DNS zone** id for each endpoint (commonly `privatelink.redis.cache.windows.net`), either resolved in-subscription via `dns_private_zone_name` (same resource group as the VNet by default, or `dns_private_zone_resource_group`), or supplied directly via `private_dns_zone_id` when it lives in another subscription.
- **azurerm** provider configured.

## Basic usage

```hcl
module "redis" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-redis-cache?ref=<version>"

  resource_group = "example-rg"

  redis = {
    name     = "redis-example"
    location = "westeurope"
    capacity = 1
    family   = "C"
    sku_name = "Standard"
  }

  private_endpoints = {
    default = {
      name                          = "pe-redis"
      custom_network_interface_name = "pe-redis-nic"
      private_service_connection = {
        is_manual_connection = false
      }

      subnet_name = "example-subnet"
      vnet = {
        name                = "example-vnet"
        resource_group_name = "example-network-rg"
      }

      # Either resolve the zone in this subscription...
      dns_private_zone_name = "privatelink.redis.cache.windows.net"
      # ...or pass an already-resolved id from another subscription instead:
      # private_dns_zone_id = "/subscriptions/<other-sub>/resourceGroups/.../providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"
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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.23.0, < 5.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.23.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_redis_cache.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |
| [azurerm_private_dns_zone.dns_private_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resources.vnet_from_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_resources.vnet_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | Map of private endpoints to create for the Redis cache, keyed by an arbitrary name. Empty map (default) skips private endpoint creation. | <pre>map(object({<br/>    name                          = string<br/>    dns_zone_group_name           = optional(string, "default")<br/>    custom_network_interface_name = string<br/>    private_service_connection = optional(object({<br/>      is_manual_connection = bool<br/>    }), { is_manual_connection = false })<br/><br/>    # Subnet where the private endpoint NIC will be placed.<br/>    subnet_name = string<br/>    vnet = optional(object({<br/>      name                = optional(string)<br/>      resource_group_name = optional(string)<br/>      tags                = optional(map(string))<br/>    }), {})<br/><br/>    # Pass an already-resolved Private DNS Zone ID (e.g. from another subscription, via a claims ref).<br/>    # When omitted, the zone is looked up in this subscription by dns_private_zone_name.<br/>    private_dns_zone_id             = optional(string)<br/>    dns_private_zone_name           = optional(string)<br/>    dns_private_zone_resource_group = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_redis"></a> [redis](#input\_redis) | n/a | <pre>object({<br/>    name                          = string<br/>    location                      = string<br/>    capacity                      = number<br/>    family                        = string<br/>    sku_name                      = string<br/>    non_ssl_port_enabled          = optional(bool)<br/>    minimum_tls_version           = optional(string)<br/>    redis_version                 = optional(number)<br/>    public_network_access_enabled = optional(bool)<br/>    zones                         = optional(list(string))<br/>    subnet_id                     = optional(string)<br/>    patch_schedule = optional(object({<br/>      day_of_week    = optional(string)<br/>      start_hour_utc = optional(number)<br/>    }))<br/>    redis_configuration = optional(object({<br/>      aof_backup_enabled                      = optional(bool)<br/>      aof_storage_connection_string_0         = optional(string)<br/>      aof_storage_connection_string_1         = optional(string)<br/>      authentication_enabled                  = optional(bool)<br/>      active_directory_authentication_enabled = optional(bool)<br/>      maxmemory_reserved                      = optional(number)<br/>      maxmemory_delta                         = optional(number)<br/>      maxmemory_policy                        = optional(string)<br/>      maxfragmentationmemory_reserved         = optional(number)<br/>      rdb_backup_enabled                      = optional(bool)<br/>      rdb_backup_frequency                    = optional(number)<br/>      rdb_backup_max_snapshot_count           = optional(number)<br/>      rdb_storage_connection_string           = optional(string)<br/>      storage_account_subscription_id         = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Redis hostname for TLS client connections. |
| <a name="output_port"></a> [port](#output\_port) | Non-SSL port of the Redis cache. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | Primary access key for the Redis cache. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint resource IDs, keyed by the private\_endpoints map key. Empty when no private endpoints were requested. |
| <a name="output_private_endpoint_private_ips"></a> [private\_endpoint\_private\_ips](#output\_private\_endpoint\_private\_ips) | Map of private IP addresses assigned to each private endpoint NIC, keyed by the private\_endpoints map key. Empty when no private endpoints were requested. |
| <a name="output_redis_connection"></a> [redis\_connection](#output\_redis\_connection) | Connection information for Redis. |
| <a name="output_redis_id"></a> [redis\_id](#output\_redis\_id) | Resource ID of the Azure Cache for Redis instance. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | Secondary access key for the Redis cache. |
| <a name="output_ssl_port"></a> [ssl\_port](#output\_ssl\_port) | TLS port exposed by the Redis cache. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/basic) — Standard-tier Redis with private endpoint; wire RG, VNet, subnet, and private DNS zone (see folder README).
- [comprehensive](https://github.com/prefapp/tfm/tree/main/modules/azure-redis-cache/_examples/comprehensive) — Illustrative YAML for Standard- vs Premium-style inputs (`values.reference.yaml`; see folder README).

## Resources

Terraform resource docs use **4.23.0** as a baseline aligned with the `azurerm` constraint in `versions.tf` (`>= 4.23.0`).

- **Azure Cache for Redis**: [https://learn.microsoft.com/azure/azure-cache-for-redis/](https://learn.microsoft.com/azure/azure-cache-for-redis/)
- **azurerm\_redis\_cache**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/redis_cache)
- **azurerm\_private\_endpoint**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/resources/private_endpoint)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->