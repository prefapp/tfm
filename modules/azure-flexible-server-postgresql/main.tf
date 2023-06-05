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

  # ok let's calculate the subnet_id
  subnet_id = lookup(local.data.subnet, "name", "NOT_DEFINED")  == "NOT_DEFINED" ? local.data.subnet.id : data.azurerm_subnet.subnet[0].id
}

#---------------------------------------------------------
#
# Password creation / control
#
#---------------------------------------------------------

## We only generate the password if necessary
resource "random_password" "password" {
  length  = 20
  special = true
}


## We only upload the password if necessary
## Once created we ignore it
resource "azurerm_key_vault_secret" "password_create" {
  count        = local.data.password.create ? 1 : 0
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = local.data.password.key_vault_secret_name
  value        = random_password.password.result
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
data "azurerm_subnet" "subnet" {

  count = lookup(local.data.subnet, "name", "NOT_DEFINED") == "NOT_DEFINED" ? 0 : 1

  name = local.data.subnet.name

  virtual_network_name = local.data.subnet.vnet.name

  resource_group_name = local.data.subnet.vnet.resource_group

}

#---------------------------------------------------------
#
# DNS management
#
#---------------------------------------------------------
data "azurerm_private_dns_zone" "private_dns_zone" {

  name = local.data.dns.private.name

  resource_group_name = local.data.dns.private.resource_group

}


#---------------------------------------------------------
#
# Server management
#
#---------------------------------------------------------

data "azurerm_resource_group" "resource_group" {

  name = local.data.resource_group.name

}

data "azurerm_postgresql_flexible_server" "postgresql_restore_original_server" {

  count = local.data.server_creation.mode == "PointInTimeRestore" ? 1 : 0

  name = local.data.server_creation.from_pitr.source_server_name

  resource_group_name = local.data.server_creation.from_pitr.source_server_resource_group

}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {

  name = local.data.server.name

  resource_group_name = local.data.resource_group.name

  location = var.location

  version = local.data.server.version

  delegated_subnet_id = local.subnet_id

  private_dns_zone_id = data.azurerm_private_dns_zone.private_dns_zone.id

  backup_retention_days = local.data.backup_retention_days

  create_mode = local.data.server_creation.mode

  point_in_time_restore_time_in_utc = local.data.server_creation.mode == "PointInTimeRestore" ? local.data.server_creation.from_pitr.pitr : null

  source_server_id = local.data.server_creation.mode == "PointInTimeRestore" ? data.azurerm_postgresql_flexible_server.postgresql_restore_original_server[0].id : null

  authentication {

    active_directory_auth_enabled = local.data.authentication.active_directory_auth_enabled

    password_auth_enabled = local.data.authentication.password_auth_enabled

  }

  maintenance_window {

    day_of_week = local.data.maintainance_window.day_of_week

    start_hour = local.data.maintainance_window.start_hour

    start_minute = local.data.maintainance_window.start_minute

  }

  administrator_login = local.data.administrator_login

  administrator_password = data.azurerm_key_vault_secret.password.value

  zone = lookup(local.data.server, "zone", null)

  storage_mb = local.data.server.disk_size

  sku_name = local.data.server.sku_name

  replication_role = lookup(local.data.server, "replication_role", "None")

  tags = local.data.server.tags

  depends_on = [

    azurerm_key_vault_secret.password_create

  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_server_conf" {

  count = length(local.data.server_parameters.azure_extensions) > 0 ? 1 : 0

  name = "azure.extensions"

  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id

  value = join(",", local.data.server_parameters.azure_extensions)

}
