# Fictitious names for terraform validate; replace before apply.
# Ensure Key Vault, VNet, and (if private) subnet + private DNS exist and match lookups.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.35.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "postgresql_flexible_server" {
  source = "../.."

  resource_group = "example-rg"

  key_vault = {
    name                = "example-kv"
    resource_group_name = "example-rg"
  }

  administrator_password_key_vault_secret_name = "pg-admin-password"

  vnet = {
    name                = "example-vnet"
    resource_group_name = "example-rg"
  }

  postgresql_flexible_server = {
    name                          = "example-pg-basic"
    location                      = "westeurope"
    version                       = 15
    public_network_access_enabled = true
    administrator_login           = "psqladmin"
    storage_mb                    = 65536
    sku_name                      = "GP_Standard_D2ds_v5"
    backup_retention_days         = 30
    maintenance_window = {
      day_of_week  = 6
      start_hour   = 0
      start_minute = 0
    }
    authentication = {
      active_directory_auth_enabled = false
      password_auth_enabled         = true
    }
  }

  firewall_rule = [
    {
      name             = "allow-single-ip"
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.10"
    }
  ]

  tags = { example = "basic" }
}
