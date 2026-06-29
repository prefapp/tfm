variable "resource_group" {
  type        = string
  description = "Name of the existing Azure Resource Group where the Managed Redis instance and private endpoint will be deployed."
}

variable "tags_from_rg" {
  type        = bool
  default     = false
  description = "When true, tags from the resource group are merged with var.tags and applied to all resources in this module."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to assign to all resources created by this module."
}

variable "vnet" {
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
  })
  default     = {}
  description = "Virtual Network details used for resolving the subnet when creating a private endpoint. Lookup can be by name + resource_group_name or by tags."
}

variable "subnet_name" {
  type        = string
  default     = null
  description = "Name of the subnet where the private endpoint NIC will be placed. Required when var.private_endpoint is set."
}

variable "dns_private_zone_name" {
  type        = string
  default     = null
  description = "Name of the Private DNS Zone for the private endpoint (e.g. privatelink.redisenterprise.cache.azure.net). Required when var.private_endpoint is set."
}

variable "managed_redis" {
  description = "Configuration for the Azure Managed Redis instance."
  type = object({
    name     = string
    location = string
    # SKU defines capacity tier and size.
    # Balanced: Balanced_B0..B1000 | ComputeOptimized: ComputeOptimized_X3..X700
    # MemoryOptimized: MemoryOptimized_M10..M700 | FlashOptimized: FlashOptimized_A250..A4500
    sku_name = string

    # Whether to enable zone-redundant high availability. Defaults to true.
    # Changing this forces recreation.
    high_availability_enabled = optional(bool, true)

    # Public network access for the cluster endpoint. Possible values: Enabled, Disabled.
    public_network_access = optional(string, "Disabled")

    # Managed identity configuration. Enables SystemAssigned, UserAssigned, or both.
    identity = optional(object({
      type         = string           # SystemAssigned | UserAssigned | SystemAssigned, UserAssigned
      identity_ids = optional(list(string)) # Required when type includes UserAssigned
    }))

    # Customer-managed key encryption. Requires a UserAssigned identity with Key Vault access.
    customer_managed_key = optional(object({
      key_vault_key_id          = string # Full versioned or versionless Key Vault key URL
      user_assigned_identity_id = string # ID of the UAI that has WrapKey/UnwrapKey on the key
    }))

    # Configuration for the implicit default database. Required when creating a new instance.
    default_database = optional(object({
      # Whether access key authentication is enabled. Defaults to false (Entra ID only).
      access_keys_authentication_enabled = optional(bool, false)

      # Redis client protocol. Encrypted (TLS) or Plaintext. Defaults to Encrypted.
      client_protocol = optional(string, "Encrypted")

      # Cluster topology policy. Changing forces database recreation and data loss.
      # EnterpriseCluster | OSSCluster | NoCluster. Defaults to OSSCluster.
      clustering_policy = optional(string, "OSSCluster")

      # Eviction policy for keys when memory pressure occurs.
      # AllKeysLFU | AllKeysLRU | AllKeysRandom | VolatileLRU | VolatileLFU
      # VolatileTTL | VolatileRandom | NoEviction. Defaults to VolatileLRU.
      eviction_policy = optional(string, "VolatileLRU")

      # Geo-replication group name. Conflicts with persistence. Changing forces recreation.
      geo_replication_group_name = optional(string)

      # Append-Only File (AOF) backup frequency. Only valid value is "1s".
      # Conflicts with persistence_redis_database_backup_frequency and geo_replication_group_name.
      persistence_append_only_file_backup_frequency = optional(string)

      # Redis Database (RDB) snapshot frequency. Possible values: 1h, 6h, 12h.
      # Conflicts with persistence_append_only_file_backup_frequency and geo_replication_group_name.
      persistence_redis_database_backup_frequency = optional(string)

      # Redis modules to load. Changing name or args forces database recreation and data loss.
      # Only RediSearch and RedisJSON are allowed with geo-replication.
      modules = optional(list(object({
        name = string           # RedisBloom | RedisTimeSeries | RediSearch | RedisJSON
        args = optional(string) # Module-specific configuration string, e.g. "ERROR_RATE 0.01"
      })), [])
    }), {})
  })


  validation {
    condition = !(
      var.managed_redis.default_database.persistence_append_only_file_backup_frequency != null &&
      var.managed_redis.default_database.persistence_redis_database_backup_frequency != null
    )
    error_message = "Only one persistence method can be configured at a time: set either persistence_append_only_file_backup_frequency (AOF) or persistence_redis_database_backup_frequency (RDB), not both."
  }

  validation {
    condition = !(
      var.managed_redis.default_database.geo_replication_group_name != null && (
        var.managed_redis.default_database.persistence_append_only_file_backup_frequency != null ||
        var.managed_redis.default_database.persistence_redis_database_backup_frequency != null
      )
    )
    error_message = "Persistence (AOF or RDB) cannot be enabled on geo-replicated databases. Remove geo_replication_group_name or the persistence configuration."
  }
}

variable "private_endpoint" {
  description = "Private endpoint configuration. Set to null to skip private endpoint creation."
  type = object({
    name                = string
    dns_zone_group_name = optional(string, "default")
    # Name for the network interface card (NIC) created for the private endpoint.
    custom_network_interface_name = string
    private_service_connection = optional(object({
      is_manual_connection = bool
    }), { is_manual_connection = false })
  })
  default = null
}

variable "access_policy_assignments" {
  description = "List of Azure AD principal object IDs to assign built-in access policies on the default database."
  type = list(object({
    object_id = string # Object ID of the Azure AD user, group, service principal, or managed identity
  }))
  default = []
}
