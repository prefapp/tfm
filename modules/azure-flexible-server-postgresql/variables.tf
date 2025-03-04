variable "subnet" {
    type = object({
        name                     = string
        vnet_name                = string
        vnet_resource_group_name = string
    })
}

variable "dns_private_zone" {
    type = object({
        name                     = string
        resource_group_name      = string
    })
}

variable "key_vault" {
    type = object({
        name                = string
        resource_group_name = string
    })
}

variable "administrator_password_key_vault_secret_name" {
    type = string
}

variable "postgres_flexible_server" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    version             = optional(number)
    administrator_login = optional(string)
    zone                = optional(string)
    storage_tier        = optional(string)
    storage_mb          = optional(number)
    sku_name            = optional(string)
    replication_role    = optional(string)
    create_mode         = optional(string)
    tags                = optional(map(string))
    maintenance_window  = optional(object({
      day_of_week  = number
      start_hour   = number
      start_minute = number
    }))
    authentication = optional(object({
      active_directory_auth_enabled = string
      password_auth_enabled         = bool
      tenant_id                     = string
    }))
  })
}

variable "postgresql_flexible_server_configuration" {
    type = object({
        name    = string
        value   = string
    })
}
