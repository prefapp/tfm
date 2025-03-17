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
      day_of_week     = string
      start_hour_utc  = number
    }))
    redis_configuration = optional(object({
      aof_backup_enabled              = bool
      aof_storage_connection_string_0 = string
      aof_storage_connection_string_1 = string
      authentication_enabled          = bool
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


