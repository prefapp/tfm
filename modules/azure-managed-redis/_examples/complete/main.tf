# Complete example: production-grade Managed Redis with all major features
# Demonstrates: MemoryOptimized SKU, zone-redundant HA, UserAssigned managed identity,
# Customer-Managed Key (CMK), RediSearch + RedisJSON modules, RDB persistence,
# private endpoint, and access policy assignments for Entra ID principals.
#
# Replace all placeholder values (IDs, names, locations) for your environment.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.70.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ---------------------------------------------------------------------------
# Supporting resources (pre-existing in a real scenario)
# ---------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = "prod-rg"
}

# User-assigned managed identity used for CMK access
resource "azurerm_user_assigned_identity" "redis_mi" {
  name                = "mi-managed-redis-prod"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

# Key Vault for Customer-Managed Key
# NOTE: purge_protection_enabled = true is required for CMK with Managed Redis
resource "azurerm_key_vault" "redis_kv" {
  name                     = "kv-managed-redis-prod"
  location                 = data.azurerm_resource_group.rg.location
  resource_group_name      = data.azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "premium"
  purge_protection_enabled = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Create", "Delete", "Get", "List",
      "Purge", "Recover", "Update",
      "GetRotationPolicy", "SetRotationPolicy",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.redis_mi.principal_id
    key_permissions = ["Get", "WrapKey", "UnwrapKey"]
  }
}

resource "azurerm_key_vault_key" "redis_cmk" {
  name         = "key-managed-redis-cmk"
  key_vault_id = azurerm_key_vault.redis_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["unwrapKey", "wrapKey"]
}

# ---------------------------------------------------------------------------
# Module call
# ---------------------------------------------------------------------------

module "managed_redis" {
  source = "../.."

  resource_group = data.azurerm_resource_group.rg.name
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
    managed-by  = "terraform"
  }

  managed_redis = {
    name                      = "managed-redis-prod"
    location                  = data.azurerm_resource_group.rg.location
    sku_name                  = "MemoryOptimized_M10"
    high_availability_enabled = true
    public_network_access     = "Disabled"

    # UserAssigned identity is required for CMK
    identity = {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.redis_mi.id]
    }

    # Encrypt at rest with a customer-managed key
    customer_managed_key = {
      key_vault_key_id          = azurerm_key_vault_key.redis_cmk.id
      user_assigned_identity_id = azurerm_user_assigned_identity.redis_mi.id
    }

    default_database = {
      # Disable access key auth — use Entra ID only (more secure)
      access_keys_authentication_enabled = false
      client_protocol                    = "Encrypted"
      clustering_policy                  = "OSSCluster"
      eviction_policy                    = "AllKeysLRU"

      # RDB snapshot every 6 hours (cannot be combined with geo_replication_group_name)
      persistence_redis_database_backup_frequency = "6h"

      # Redis modules — changing name/args forces database recreation
      modules = [
        { name = "RediSearch" },
        { name = "RedisJSON" },
      ]
    }
  }

  private_endpoint = {
    name                          = "pe-managed-redis-prod"
    dns_zone_group_name           = "default"
    custom_network_interface_name = "pe-managed-redis-prod-nic"
    private_service_connection = {
      is_manual_connection = false
    }
  }

  # Grant read/write access to two Entra ID principals
  access_policy_assignments = [
    { object_id = "00000000-0000-0000-0000-000000000001" }, # app service principal
    { object_id = "00000000-0000-0000-0000-000000000002" }, # ops Entra group
  ]
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "managed_redis_id" {
  value = module.managed_redis.managed_redis_id
}

output "hostname" {
  value = module.managed_redis.hostname
}

output "default_database_port" {
  value = module.managed_redis.default_database_port
}

output "private_endpoint_ip" {
  value = module.managed_redis.private_endpoint_private_ip
}
