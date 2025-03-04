variable "subnet" {
    type = map({
        name                     = string
        virtual_network_name     = string
        resource_group_name      = string
    })
}

variable "dns_private" {
    type = map({
        zone                     = string
        resource_group_name      = string
    })
}

variable "key_vault" {
    type = map({
        name                = string
        resource_group_name = string
    })
}

variable "administrator_password_keyvault_secret_name" {
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
    maintenance_window = optional(map({
      day_of_week  = number
      start_hour   = number
      start_minute = number
    }))
    authentication = optional(map({
      active_directory_auth_enabled = string
      password_auth_enabled         = bool
    }))
  })
}

variable "azurerm_postgresql_flexible_server_configuration" {
    type = map({
        name    = string
        value   = string
    })
}
