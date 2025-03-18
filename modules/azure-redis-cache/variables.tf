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

variable "vnet" {
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
  })
  default = {}
}

variable "subnet_name" {
  type = string
}

variable "dns_private_zone_name" {
  type = string
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
      day_of_week     = optional(string)
      start_hour_utc  = optional(number)
    }))
    redis_configuration = optional(object({
      aof_backup_enabled              = optional(bool)
      aof_storage_connection_string_0 = optional(string)
      aof_storage_connection_string_1 = optional(string)
      authentication_enabled          = optional(bool)
      maxmemory_reserved              = optional(number)
      maxmemory_delta                 = optional(number)
      maxmemory_policy                = optional(string)
      maxfragmentationmemory_reserved = optional(number)
      rdb_backup_frequency            = optional(number)
      rdb_backup_max_snapshot_count   = optional(number)
      rdb_storage_connection_string   = optional(string)
      }))
  })
}

variable "private_endpoint" {
  type = object({
    name = string
    custom_network_interface_name = string
    private_service_connection = optional(object({
      is_manual_connection = bool
    }))
  })
}


