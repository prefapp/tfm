# **Azure Managed Redis Terraform Module**

## Overview

This module provisions an **Azure Managed Redis** instance (`azurerm_managed_redis`) — the next-generation, fully managed Redis service on Azure that supersedes Redis Enterprise. It deploys the cluster and its implicit default database, and optionally attaches a **private endpoint** with DNS zone group and **access policy assignments** for Azure AD principals.

The module resolves an existing **resource group**, optionally discovers a **virtual network** by name, resource group, or **tags**, and reads both a **subnet** and a **private DNS zone** for private connectivity. All resources receive a unified tag set, optionally merged from the resource group.

Target use cases span from lightweight development clusters (`Balanced_B0`) up to production-grade, zone-redundant, CMK-encrypted, geo-replicated deployments with Redis modules and fine-grained authentication policies.

## Key Features

- **SKU flexibility**: supports all tier families — `Balanced`, `ComputeOptimized`, `MemoryOptimized`, and `FlashOptimized` — in all documented sizes.
- **High availability**: zone-redundant HA enabled by default (`high_availability_enabled = true`); can be disabled for dev/test at create time.
- **Private connectivity**: optional private endpoint with `redisEnterprise` subresource, DNS zone group, and custom NIC name. Public network access is `Disabled` by default.
- **Managed identity**: supports `SystemAssigned`, `UserAssigned`, or both; required for CMK scenarios.
- **Customer-Managed Key (CMK)**: encrypt cluster data at rest with a Key Vault key via a `UserAssigned` identity.
- **Database configuration**: full control over `clustering_policy`, `eviction_policy`, `client_protocol`, and access key authentication.
- **Persistence**: choose AOF (1-second frequency) or RDB (1 h / 6 h / 12 h snapshots); both conflict with geo-replication.
- **Geo-replication**: set `geo_replication_group_name` to join a geo-replication group; use `azurerm_managed_redis_geo_replication` to link multiple clusters.
- **Redis modules**: load `RedisBloom`, `RedisTimeSeries`, `RediSearch`, and/or `RedisJSON` with optional module arguments; changing these forces database recreation.
- **Access policy assignments**: assign built-in access policies to Azure AD users, groups, service principals, or managed identities on the default database.
- **Tags**: optional merge from the resource group (`tags_from_rg = true`).

## Basic Usage

### Minimal configuration — Balanced B1 with private endpoint

```hcl
module "managed_redis" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-managed-redis?ref=<version>"

  resource_group = "example-rg"
  subnet_name    = "example-subnet"

  dns_private_zone_name = "privatelink.redisenterprise.cache.azure.net"

  vnet = {
    name                = "example-vnet"
    resource_group_name = "example-network-rg"
  }

  managed_redis = {
    name     = "managed-redis-example"
    location = "westeurope"
    sku_name = "Balanced_B1"
  }

  private_endpoint = {
    name                          = "pe-managed-redis"
    custom_network_interface_name = "pe-managed-redis-nic"
  }
}
```

### Production configuration — MemoryOptimized with CMK, modules, and persistence

```hcl
module "managed_redis" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-managed-redis?ref=<version>"

  resource_group = "prod-rg"
  subnet_name    = "data-subnet"

  dns_private_zone_name = "privatelink.redisenterprise.cache.azure.net"

  vnet = {
    name                = "prod-vnet"
    resource_group_name = "prod-network-rg"
  }

  tags_from_rg = true
  tags = {
    environment = "production"
    team        = "platform"
  }

  managed_redis = {
    name                      = "managed-redis-prod"
    location                  = "westeurope"
    sku_name                  = "MemoryOptimized_M10"
    high_availability_enabled = true
    public_network_access     = "Disabled"

    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/.../resourceGroups/prod-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/redis-mi"]
    }

    customer_managed_key = {
      key_vault_key_id          = "https://prod-kv.vault.azure.net/keys/redis-cmk/abc123"
      user_assigned_identity_id = "/subscriptions/.../resourceGroups/prod-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/redis-mi"
    }

    default_database = {
      access_keys_authentication_enabled          = false
      client_protocol                             = "Encrypted"
      clustering_policy                           = "OSSCluster"
      eviction_policy                             = "AllKeysLRU"
      persistence_redis_database_backup_frequency = "6h"

      modules = [
        { name = "RediSearch" },
        { name = "RedisJSON" },
      ]
    }
  }

  private_endpoint = {
    name                          = "pe-managed-redis-prod"
    custom_network_interface_name = "pe-managed-redis-prod-nic"
    private_service_connection = {
      is_manual_connection = false
    }
  }

  access_policy_assignments = [
    { object_id = "00000000-0000-0000-0000-000000000001" }, # app service principal
    { object_id = "00000000-0000-0000-0000-000000000002" }, # ops team group
  ]
}
```

## File Structure

```
.
├── .terraform-docs.yml
├── README.md
├── access-policy-assignment.tf
├── data.tf
├── managed-redis.tf
├── outputs.tf
├── private-endpoint.tf
├── variables.tf
├── versions.tf
├── docs/
│   ├── header.md
│   └── footer.md
└── _examples/
    ├── basic/
    │   └── main.tf
    └── complete/
        └── main.tf
```

## Notes

1. **Provider version**: `azurerm_managed_redis` requires **azurerm >= 4.70.0**. Use the latest available version for best compatibility.
2. **Provisioning time**: Azure Managed Redis clusters typically take **30–45 minutes** to provision.
3. **High availability**: `high_availability_enabled` can only be set at **create time**; changing it forces resource replacement.
4. **Clustering policy**: changing `clustering_policy` forces **database recreation**; data will be lost and the cluster will be unavailable during the operation.
5. **Geo-replication vs. persistence**: AOF and RDB persistence are **mutually exclusive** with geo-replication. The module enforces this with input validation.
6. **Redis modules**: changing `module.name` or `module.args` forces **database recreation** and data loss.
7. **CMK**: `customer_managed_key` requires a `UserAssigned` identity with `WrapKey` and `UnwrapKey` permissions on the Key Vault key. The Key Vault must have `purge_protection_enabled = true`.
8. **Access key auth**: `primary_access_key` and `secondary_access_key` outputs are only populated when `access_keys_authentication_enabled = true`. Use Entra ID authentication (the default) where possible.
9. **Private DNS zone**: the DNS zone is resolved in the same resource group used for the VNet (`vnet.resource_group_name` or inferred from tag lookup). If the zone lives in a separate RG, use `vnet.resource_group_name` to point to that RG, or manage the `azurerm_private_dns_zone_virtual_network_link` separately.
10. **SKU downgrades**: scaling down to a lower SKU tier may be restricted by Azure and could force resource replacement. Refer to the [Azure scaling documentation](https://learn.microsoft.com/azure/redis/how-to-scale).
