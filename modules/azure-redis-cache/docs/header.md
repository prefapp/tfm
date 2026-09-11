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
