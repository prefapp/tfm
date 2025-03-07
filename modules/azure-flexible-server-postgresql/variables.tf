variable "resource_group" {
  type = string
}

variable "subnet" {
  type = object({
    name                     = string
    vnet_name                = optional(string)
    vnet_resource_group_name = optional(string)
  })
}

variable "admin_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "dns_private_zone" {
  type = object({
    name                = string
    resource_group_name = optional(string)
  })
}

variable "key_vault" {
  type = object({
    name                = optional(string)
    resource_group_name = optional(string)
  })
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
  type = map(string)
  default = {}
}

variable "postgresql_flexible_server" {
  type = object({
    name                = string
    location            = string
    version             = optional(number)
    administrator_login = optional(string)
    zone                = optional(string)
    storage_tier        = optional(string)
    storage_mb          = optional(number)
    sku_name            = optional(string)
    replication_role    = optional(string)
    create_mode         = optional(string)
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
  type = object[{
    vnet_name                = optional(string)
    vnet_resource_group      = optional(string)
  }]
}

variable "postgresql_flexible_server_configuration" {
  type = map(object({
    name  = optional(string)
    value = optional(string)
  }))
}
