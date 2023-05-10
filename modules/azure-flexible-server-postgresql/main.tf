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

resource "azurerm_resource_group" "resource_group" {
  name     = "fs-psql-${var.env}-${var.postgresql_name}"
  location = var.location
  tags = {
    env      = var.env
    cliente  = var.cliente
    producto = var.producto
  }
}

data "azurerm_virtual_network" "virtual_network" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_rg
}

data "azurerm_key_vault" "key_vault" {
  name                = var.password_key_vault
  resource_group_name = var.password_key_vault_rg
}

data "azurerm_key_vault_secret" "password" {
  name         = var.password_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                  = "${var.env}-${var.postgresql_name}"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = var.location
  version               = var.postgresql_version
  delegated_subnet_id   = "${data.azurerm_virtual_network.virtual_network.id}/subnets/${var.virtual_network_subnet_name}"
  backup_retention_days = var.backup_retention_days
  authentication {
    active_directory_auth_enabled = var.authentication_active_directory_auth_enabled
    password_auth_enabled         = var.authentication_password_auth_enabled
  }
  maintenance_window {
    day_of_week  = var.postgresql_maintenance_window_day_of_week
    start_hour   = var.postgresql_maintenance_window_start_hour
    start_minute = var.postgresql_maintenance_window_start_minute
  }
  administrator_login    = var.administrator_login
  administrator_password = data.azurerm_key_vault_secret.password.value
  zone                   = "1"
  storage_mb             = var.postgresql_disk_size
  sku_name               = var.postgresql_sku_size
  tags = {
    env      = var.env
    cliente  = var.cliente
    producto = var.producto
  }
  depends_on = [
    azurerm_resource_group.resource_group
  ]
}
