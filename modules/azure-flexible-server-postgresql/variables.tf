variable "resource_group" {
  type = string
}

variable "password_length" {
  type    = number
  default = 20
}

variable "subnet_name" {
  type    = string
  default = null
}

variable "dns_private_zone_name" {
  type    = string
  default = null
}

variable "key_vault" {
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
  })
  default = {}
}

variable "administrator_password_key_vault_secret_name" {
  type    = string
  default = null
}

variable "tags_from_rg" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "postgresql_flexible_server" {
  type = object({
    name                              = string
    location                          = string
    version                           = optional(number)
    public_network_access_enabled     = optional(bool)
    administrator_login               = optional(string)
    zone                              = optional(string)
    storage_tier                      = optional(string)
    storage_mb                        = optional(number)
    sku_name                          = optional(string)
    replication_role                  = optional(string)
    create_mode                       = optional(string)
    source_server_id                  = optional(string)
    point_in_time_restore_time_in_utc = optional(string)
    backup_retention_days             = optional(number)
    maintenance_window = optional(object({
      day_of_week  = number
      start_hour   = number
      start_minute = number
    }))
    authentication = optional(object({
      active_directory_auth_enabled = bool
      password_auth_enabled         = bool
      tenant_id                     = optional(string)
    }))
  })
}

variable "vnet" {
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
  })
  default = {}
}

variable "postgresql_flexible_server_configuration" {
  type = map(object({
    name  = optional(string)
    value = optional(string)
  }))
}

variable "firewall_rule" {
  type = list(object({
    name             = optional(string)
    start_ip_address = optional(string)
    end_ip_address   = optional(string)
  }))
  default = []
}
