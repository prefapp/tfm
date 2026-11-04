# Azure Files share backup example. The source storage account and share must exist.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.6.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "backup" {
  name     = "example-file-share-backup-rg"
  location = "westeurope"
}

resource "azurerm_storage_account" "source" {
  name                     = "examplesabackupfiles"
  resource_group_name      = azurerm_resource_group.backup.name
  location                 = azurerm_resource_group.backup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "source" {
  name                 = "documents"
  storage_account_name = azurerm_storage_account.source.name
  quota                = 5
}

module "storage_backup" {
  source = "../.."

  backup_resource_group_name = azurerm_resource_group.backup.name
  storage_account_id         = azurerm_storage_account.source.id

  backup_share = {
    policy_name                  = "daily-file-share-backup"
    recovery_services_vault_name = "example-file-share-vault"
    sku                          = "Standard"
    source_file_share_name       = [azurerm_storage_share.source.name]
    backup = {
      frequency = "Daily"
      time      = "02:00"
    }
    retention_daily = {
      count = 30
    }
  }
}
