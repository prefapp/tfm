terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.55.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {

  # let's read the data first
  data = var.data
}

#---------------------------------------------------------
#
# Password creation / control
#
#---------------------------------------------------------

## We only generate the password if necessary
resource "random_password" "password" {
  length           = 20
  special          = true
}


## We only upload the password if necessary
## Once created we ignore it
resource "azurerm_key_vault_secret" "password_create" {
  count            = local.data.password.create ? 1 : 0
  key_vault_id     = data.azurerm_key_vault.key_vault.id
  name             = local.data.password.key_vault_secret_name
  value            = random_password.password.result
  lifecycle {

    ignore_changes = [value]
  }
}

#
# Checkers and data access
#
data "azurerm_key_vault" "key_vault" {
  name                = local.data.password.key_vault_name
  resource_group_name = local.data.password.key_vault_resource_group
}

data "azurerm_key_vault_secrets" "check_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "password" {
  name         = local.data.password.key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
  
  depends_on = [
  
    azurerm_key_vault_secret.password_create

  ]
}


#---------------------------------------------------------
#
# Network management
#
#---------------------------------------------------------

resource "azurerm_virtual_network" "virtual_network_create" {
  count = local.data.virtual_network.create ? 1 : 0
  name  = local.data.virtual_network.name
  resource_group_name = local.data.virtual_network.resource_group
  address_space = local.data.virtual_network.address_space
  location = var.location
  
}

resource "azurerm_subnet" "subnet_create" {

  count = local.data.subnet.create ? 1 : 0

  name                 = local.data.subnet.name

  resource_group_name  = data.azurerm_virtual_network.virtual_network.resource_group_name

  virtual_network_name = data.azurerm_virtual_network.virtual_network.name

  address_prefixes     = local.data.subnet.address_prefixes

  service_endpoints    = ["Microsoft.Storage"]

  delegation {

    name = "fs"

    service_delegation {

      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [

        "Microsoft.Network/virtualNetworks/subnets/join/action",

      ]

    }

  }

}

data "azurerm_virtual_network" "virtual_network" {

  name                = local.data.virtual_network.name

  resource_group_name = local.data.virtual_network.resource_group

  depends_on = [
  
    azurerm_virtual_network.virtual_network_create

  ]
}

data "azurerm_subnet" "subnet" {

  name                  = local.data.subnet.name

  virtual_network_name  = local.data.virtual_network.name

  resource_group_name   = local.data.virtual_network.resource_group

  depends_on = [
  
    azurerm_virtual_network.virtual_network_create,

    azurerm_subnet.subnet_create

  ]
}

#---------------------------------------------------------
#
# DNS management
#
#---------------------------------------------------------
resource "azurerm_private_dns_zone" "private_dns_zone_create" {

  count		      = local.data.dns.private.create ? 1 : 0

  name                = local.data.dns.private.name

  resource_group_name = local.data.dns.private.resource_group

  depends_on = [
  
    azurerm_virtual_network.virtual_network_create,

  ]

}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link_create" {

  count		      = local.data.dns.private.create ? 1 : 0

  name                  = local.data.dns.private.name

  private_dns_zone_name = local.data.dns.private.name

  virtual_network_id    = data.azurerm_virtual_network.virtual_network.id

  resource_group_name   = local.data.dns.private.resource_group

  depends_on = [
  
    azurerm_private_dns_zone.private_dns_zone_create

  ]
}

data "azurerm_private_dns_zone" "private_dns_zone" {

  name                = local.data.dns.private.name

  resource_group_name = local.data.dns.private.resource_group

  depends_on =  [

    azurerm_private_dns_zone.private_dns_zone_create

  ]
}


#---------------------------------------------------------
#
# Server management
#
#---------------------------------------------------------

resource "azurerm_resource_group" "resource_group_create" {
  count = local.data.resource_group.create ? 1 : 0
  name     = local.data.resource_group.name
  location = var.location
  tags = local.data.tags
}

data "azurerm_resource_group" "resource_group" {

  name     = local.data.resource_group.name

  depends_on = [

    azurerm_resource_group.resource_group_create

  ]
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {

  name                  = local.data.server.name

  resource_group_name   = local.data.resource_group.name

  location              = var.location

  version               = local.data.server.version

  delegated_subnet_id   = "${data.azurerm_virtual_network.virtual_network.id}/subnets/${local.data.subnet.name}"

  private_dns_zone_id   = data.azurerm_private_dns_zone.private_dns_zone.id

  backup_retention_days = local.data.backup_retention_days

  authentication {

    active_directory_auth_enabled = local.data.authentication.active_directory_auth_enabled

    password_auth_enabled         = local.data.authentication.password_auth_enabled

  }

  maintenance_window {

    day_of_week  = local.data.maintainance_window.day_of_week

    start_hour   = local.data.maintainance_window.start_hour

    start_minute = local.data.maintainance_window.start_minute

  }

  administrator_login    = local.data.administrator_login

  administrator_password = data.azurerm_key_vault_secret.password.value

  zone                   = "1"

  storage_mb             = local.data.server.disk_size

  sku_name               = local.data.server.sku_name

  tags                   = local.data.server.tags

  depends_on = [

    azurerm_resource_group.resource_group_create,

    azurerm_virtual_network.virtual_network_create,

    azurerm_key_vault_secret.password_create

  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_server_conf" {

  count = length(local.data.server_parameters.azure_extensions) > 0 ? 1 : 0

  name      = "azure.extensions"

  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id

  value = join(",", local.data.server_parameters.azure_extensions)

}
