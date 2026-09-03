<!-- BEGIN_TF_DOCS -->
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
9. **Private DNS zone**: the DNS zone is resolved with `resource_group_name = coalesce(var.dns_private_zone_resource_group, var.vnet.resource_group_name, local.vnet_resource_group_from_data)`. By default the VNet’s resource group is used, but you can set `dns_private_zone_resource_group` to point to a different RG (e.g. when the private DNS zone is consolidated in a central subscription).
10. **SKU downgrades**: scaling down to a lower SKU tier may be restricted by Azure and could force resource replacement. Refer to the [Azure scaling documentation](https://learn.microsoft.com/azure/redis/how-to-scale).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.70.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.70.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_redis.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis) | resource |
| [azurerm_managed_redis_access_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_dns_zone.dns_private_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resources.vnet_from_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy_assignments"></a> [access\_policy\_assignments](#input\_access\_policy\_assignments) | List of Azure AD principal object IDs to assign built-in access policies on the default database. | <pre>list(object({<br/>    object_id = string # Object ID of the Azure AD user, group, service principal, or managed identity<br/>  }))</pre> | `[]` | no |
| <a name="input_dns_private_zone_name"></a> [dns\_private\_zone\_name](#input\_dns\_private\_zone\_name) | Name of the Private DNS Zone for the private endpoint (e.g. privatelink.redisenterprise.cache.azure.net). Required when var.private\_endpoint is set. | `string` | `null` | no |
| <a name="input_dns_private_zone_resource_group"></a> [dns\_private\_zone\_resource\_group](#input\_dns\_private\_zone\_resource\_group) | Override resource group for Private DNS Zone lookup. When null, falls back to vnet.resource\_group\_name. | `string` | `null` | no |
| <a name="input_managed_redis"></a> [managed\_redis](#input\_managed\_redis) | Configuration for the Azure Managed Redis instance. | <pre>object({<br/>    name     = string<br/>    location = string<br/>    # SKU defines capacity tier and size.<br/>    # Balanced: Balanced_B0..B1000 | ComputeOptimized: ComputeOptimized_X3..X700<br/>    # MemoryOptimized: MemoryOptimized_M10..M700 | FlashOptimized: FlashOptimized_A250..A4500<br/>    sku_name = string<br/><br/>    # Whether to enable zone-redundant high availability. Defaults to true.<br/>    # Changing this forces recreation.<br/>    high_availability_enabled = optional(bool, true)<br/><br/>    # Public network access for the cluster endpoint. Possible values: Enabled, Disabled.<br/>    public_network_access = optional(string, "Disabled")<br/><br/>    # Managed identity configuration. Enables SystemAssigned, UserAssigned, or both.<br/>    identity = optional(object({<br/>      type         = string           # SystemAssigned | UserAssigned<br/>      identity_ids = optional(list(string)) # Required when type includes UserAssigned<br/>    }))<br/><br/>    # Customer-managed key encryption. Requires a UserAssigned identity with Key Vault access.<br/>    customer_managed_key = optional(object({<br/>      key_vault_key_id          = string # Full versioned or versionless Key Vault key URL<br/>      user_assigned_identity_id = string # ID of the UAI that has WrapKey/UnwrapKey on the key<br/>    }))<br/><br/>    # Configuration for the implicit default database. Required when creating a new instance.<br/>    default_database = optional(object({<br/>      # Whether access key authentication is enabled. Defaults to false (Entra ID only).<br/>      access_keys_authentication_enabled = optional(bool, false)<br/><br/>      # Redis client protocol. Encrypted (TLS) or Plaintext. Defaults to Encrypted.<br/>      client_protocol = optional(string, "Encrypted")<br/><br/>      # Cluster topology policy. Changing forces database recreation and data loss.<br/>      # EnterpriseCluster | OSSCluster | NoCluster. Defaults to OSSCluster.<br/>      clustering_policy = optional(string, "OSSCluster")<br/><br/>      # Eviction policy for keys when memory pressure occurs.<br/>      # AllKeysLFU | AllKeysLRU | AllKeysRandom | VolatileLRU | VolatileLFU<br/>      # VolatileTTL | VolatileRandom | NoEviction. Defaults to VolatileLRU.<br/>      eviction_policy = optional(string, "VolatileLRU")<br/><br/>      # Geo-replication group name. Conflicts with persistence. Changing forces recreation.<br/>      geo_replication_group_name = optional(string)<br/><br/>      # Append-Only File (AOF) backup frequency. Only valid value is "1s".<br/>      # Conflicts with persistence_redis_database_backup_frequency and geo_replication_group_name.<br/>      persistence_append_only_file_backup_frequency = optional(string)<br/><br/>      # Redis Database (RDB) snapshot frequency. Possible values: 1h, 6h, 12h.<br/>      # Conflicts with persistence_append_only_file_backup_frequency and geo_replication_group_name.<br/>      persistence_redis_database_backup_frequency = optional(string)<br/><br/>      # Redis modules to load. Changing name or args forces database recreation and data loss.<br/>      # Only RediSearch and RedisJSON are allowed with geo-replication.<br/>      modules = optional(list(object({<br/>        name = string           # RedisBloom | RedisTimeSeries | RediSearch | RedisJSON<br/>        args = optional(string) # Module-specific configuration string, e.g. "ERROR_RATE 0.01"<br/>      })), [])<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Private endpoint configuration. Set to null to skip private endpoint creation. | <pre>object({<br/>    name                = string<br/>    dns_zone_group_name = optional(string, "default")<br/>    # Name for the network interface card (NIC) created for the private endpoint.<br/>    custom_network_interface_name = string<br/>    private_service_connection = optional(object({<br/>      is_manual_connection = bool<br/>    }), { is_manual_connection = false })<br/>  })</pre> | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the existing Azure Resource Group where the Managed Redis instance and private endpoint will be deployed. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet where the private endpoint NIC will be placed. Required when var.private\_endpoint is set. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to assign to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | When true, tags from the resource group are merged with var.tags and applied to all resources in this module. | `bool` | `false` | no |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | Virtual Network details used for resolving the subnet when creating a private endpoint. Lookup can be by name + resource\_group\_name or by tags. | <pre>object({<br/>    name                = optional(string)<br/>    resource_group_name = optional(string)<br/>    tags                = optional(map(string))<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_policy_assignment_ids"></a> [access\_policy\_assignment\_ids](#output\_access\_policy\_assignment\_ids) | Map of access policy assignment IDs keyed by the index of the input list. |
| <a name="output_default_database_id"></a> [default\_database\_id](#output\_default\_database\_id) | Resource ID of the default Managed Redis database. |
| <a name="output_default_database_port"></a> [default\_database\_port](#output\_default\_database\_port) | TCP port of the default Managed Redis database endpoint. |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | DNS hostname of the Managed Redis cluster endpoint. |
| <a name="output_managed_redis_id"></a> [managed\_redis\_id](#output\_managed\_redis\_id) | Resource ID of the Azure Managed Redis instance. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | Primary access key for the Managed Redis default database. Only populated when access\_keys\_authentication\_enabled = true. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Resource ID of the private endpoint. Null when no private endpoint was requested. |
| <a name="output_private_endpoint_private_ip"></a> [private\_endpoint\_private\_ip](#output\_private\_endpoint\_private\_ip) | Private IP address assigned to the private endpoint NIC. Null when no private endpoint was requested. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | Secondary access key for the Managed Redis default database. Only populated when access\_keys\_authentication\_enabled = true. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-managed-redis/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-managed-redis/_examples/basic) — Balanced\_B1 cluster with a private endpoint and DNS zone group; minimal configuration covering the required inputs.
- [complete](https://github.com/prefapp/tfm/tree/main/modules/azure-managed-redis/_examples/complete) — Production-grade MemoryOptimized cluster with zone-redundant HA, Customer-Managed Key encryption, UserAssigned managed identity, RediSearch and RedisJSON modules, RDB persistence, access policy assignments, and a private endpoint.

## Resources

- **Azure Managed Redis overview**: [https://learn.microsoft.com/azure/redis/overview](https://learn.microsoft.com/azure/redis/overview)
- **azurerm\_managed\_redis**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis)
- **azurerm\_managed\_redis\_access\_policy\_assignment**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis\_access\_policy\_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis\_access\_policy\_assignment)
- **azurerm\_managed\_redis\_geo\_replication**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis\_geo\_replication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis\_geo\_replication)
- **azurerm\_private\_endpoint**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- **Private endpoint subresources (Azure Managed Redis = redisEnterprise)**: [https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource](https://learn.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource)
- **Azure Managed Redis SKUs**: [https://learn.microsoft.com/azure/redis/overview-sku-selection](https://learn.microsoft.com/azure/redis/overview-sku-selection)
- **Azure Managed Redis persistence**: [https://learn.microsoft.com/azure/redis/how-to-persistence](https://learn.microsoft.com/azure/redis/how-to-persistence)
- **Azure Managed Redis geo-replication**: [https://learn.microsoft.com/azure/redis/how-to-active-geo-replication](https://learn.microsoft.com/azure/redis/how-to-active-geo-replication)
- **Azure Managed Redis modules**: [https://learn.microsoft.com/azure/redis/redis-modules](https://learn.microsoft.com/azure/redis/redis-modules)
- **Migrating from Redis Enterprise to Managed Redis**: [https://learn.microsoft.com/azure/redis/migrate/migrate-overview](https://learn.microsoft.com/azure/redis/migrate/migrate-overview)
- **Terraform AzureRM Provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->