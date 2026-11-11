variable "resource_group" {
  type = string
}

variable "tags_from_rg" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "redis" {
  type = object({
    name                          = string
    location                      = string
    capacity                      = number
    family                        = string
    sku_name                      = string
    non_ssl_port_enabled          = optional(bool)
    minimum_tls_version           = optional(string)
    redis_version                 = optional(number)
    public_network_access_enabled = optional(bool)
    zones                         = optional(list(string))
    subnet_id                     = optional(string)
    patch_schedule = optional(object({
      day_of_week    = optional(string)
      start_hour_utc = optional(number)
    }))
    redis_configuration = optional(object({
      aof_backup_enabled                      = optional(bool)
      aof_storage_connection_string_0         = optional(string)
      aof_storage_connection_string_1         = optional(string)
      authentication_enabled                  = optional(bool)
      active_directory_authentication_enabled = optional(bool)
      maxmemory_reserved                      = optional(number)
      maxmemory_delta                         = optional(number)
      maxmemory_policy                        = optional(string)
      maxfragmentationmemory_reserved         = optional(number)
      rdb_backup_enabled                      = optional(bool)
      rdb_backup_frequency                    = optional(number)
      rdb_backup_max_snapshot_count           = optional(number)
      rdb_storage_connection_string           = optional(string)
      storage_account_subscription_id         = optional(string)
    }))
  })
}

variable "private_endpoints" {
  description = "Map of private endpoints to create for the Redis cache, keyed by an arbitrary name. Empty map (default) skips private endpoint creation."
  type = map(object({
    name                          = string
    dns_zone_group_name           = optional(string, "default")
    custom_network_interface_name = string
    private_service_connection = optional(object({
      is_manual_connection = bool
    }), { is_manual_connection = false })

    # Subnet where the private endpoint NIC will be placed.
    subnet_name = string
    vnet = optional(object({
      name                = optional(string)
      resource_group_name = optional(string)
      tags                = optional(map(string))
    }), {})

    # Pass an already-resolved Private DNS Zone ID (e.g. from another subscription, via a claims ref).
    # When omitted, the zone is looked up in this subscription by dns_private_zone_name.
    private_dns_zone_id             = optional(string)
    dns_private_zone_name           = optional(string)
    dns_private_zone_resource_group = optional(string)
  }))
  default = {}
  nullable = false

  validation {
    condition = alltrue([
      for k, v in var.private_endpoints : (try(trimspace(v.private_dns_zone_id), "") != "") != (try(trimspace(v.dns_private_zone_name), "") != "")
    ])
    error_message = "Each private endpoint must set exactly one of private_dns_zone_id or dns_private_zone_name."
  }

  validation {
    condition = alltrue([
      for k, v in var.private_endpoints : (
        (
          try(trimspace(v.vnet.name), "") != "" &&
          try(trimspace(v.vnet.resource_group_name), "") != ""
        ) ||
        length(coalesce(v.vnet.tags, {})) > 0
      )
    ])
    error_message = "Each private endpoint must set either vnet.name and vnet.resource_group_name, or vnet.tags, so the subnet can be resolved."
  }
}
