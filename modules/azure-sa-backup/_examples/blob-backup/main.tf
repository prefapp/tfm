# Blob container backup example. The vault identity receives access to this storage account.

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
  name     = "example-blob-backup-rg"
  location = "westeurope"
}

resource "azurerm_storage_account" "source" {
  name                     = "examplesabackupblobs"
  resource_group_name      = azurerm_resource_group.backup.name
  location                 = azurerm_resource_group.backup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "source" {
  name                  = "archive"
  storage_account_name  = azurerm_storage_account.source.name
  container_access_type = "private"
}

module "storage_backup" {
  source = "../.."

  backup_resource_group_name = azurerm_resource_group.backup.name
  storage_account_id         = azurerm_storage_account.source.id

  backup_blob = {
    vault_name                      = "example-blob-backup-vault"
    datastore_type                  = "VaultStore"
    redundancy                      = "LocallyRedundant"
    identity_type                   = "SystemAssigned"
    role_assignment                 = "Storage Account Backup Contributor"
    instance_blob_name              = "example-blob-backup"
    storage_account_container_names = [azurerm_storage_container.source.name]
    policy = {
      name                                   = "daily-blob-backup"
      backup_repeating_time_intervals        = ["R/2024-01-01T02:00:00+00:00/PT24H"]
      operational_default_retention_duration = "P30D"
    }
  }
}
