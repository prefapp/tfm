# Azure Cache for Redis Terraform module (`azure-redis-cache`)

## Overview

This module provisions **Azure Cache for Redis** (`azurerm_redis_cache`) together with a **private endpoint** and private **DNS zone** association. It looks up an existing **resource group**, resolves a **virtual network** by name (and resource group) or by **tags**, and reads a **subnet** and **private DNS zone** for connectivity.

The module includes **`moved`** blocks for state migration from older resource addresses.

## Key features

- **Networking**: Private endpoint to Redis (`redisCache` subresource) with DNS zone group.
- **VNet resolution**: `vnet.name` + `vnet.resource_group_name` and/or `vnet.tags` via `azurerm_resources`.
- **Tags**: Optional merge from the Redis resource group when `tags_from_rg = true`.
- **Premium options**: Optional `patch_schedule`; when `redis.family = "P"` (Premium), **`redis_configuration` must be set** in the current implementation (the resource block always dereferences `redis.redis_configuration.*`).

## Notes

1. When **`redis.family` is `"P"`** (Premium), the module always opens a **`redis_configuration`** block on `azurerm_redis_cache` and reads **`redis.redis_configuration.*`**; supply a suitable **`redis_configuration`** object for Premium or plan/apply may fail.
2. You can locate the VNet by **`name` + `resource_group_name`** or by **`tags`** (see `data.tf`).
3. Setting **`redis.subnet_id`** on the cache is incompatible with using this module’s **private endpoint** pattern for the same workflow; see [Azure Redis VNet documentation](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-premium-vnet).
4. Creating a Redis instance often takes **on the order of ~25 minutes**.
5. **`private_endpoint.private_service_connection`** must be provided (with **`is_manual_connection`**) — the module references it directly; omitting the block causes evaluation errors.
6. **`dns_private_zone_name`** is resolved with **`resource_group_name = coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data)`** (the **VNet’s resource group**), not a separate DNS resource group. Layouts with the private DNS zone in another RG are **not supported** by the current module unless that zone happens to live in the same RG as the resolved VNet.

## Prerequisites

- Existing **resource group** for Redis and the private endpoint.
- **Virtual network** and **subnet** suitable for the private endpoint.
- **Private DNS zone** for Redis private link (commonly `privatelink.redis.cache.windows.net`) **in the same resource group the module uses for the VNet** (`vnet.resource_group_name` or the RG inferred from tag-based VNet lookup)—not a separate “shared DNS” RG unless it is that same RG.
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
