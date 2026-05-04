# Minimal example: replace names, subscription, and ensure disks exist before apply.

terraform {
  required_version = ">= 1.7.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vault" {
  name     = "example-disk-backup-rg"
  location = "westeurope"
}

module "disk_backup" {
  source = "../.."

  resource_group_name = azurerm_resource_group.vault.name
  vault_name          = "example-disk-backup-vault"

  datastore_type             = "VaultStore"
  redundancy                 = "LocallyRedundant"
  soft_delete                = "Off"
  retention_duration_in_days = 14

  backup_policies = [
    {
      name                            = "daily"
      backup_repeating_time_intervals = ["R/2024-10-17T11:29:40+00:00/PT24H"]
      default_retention_duration      = "P7D"
      time_zone                       = "Coordinated Universal Time"
      retention_rules = [
        {
          name     = "Daily"
          duration = "P7D"
          priority = 25
          criteria = { absolute_criteria = "FirstOfDay" }
        }
      ]
    }
  ]

  # Source disks must exist in the given resource groups; snapshot RG is always resource_group_name above.
  backup_instances = [
    {
      disk_name           = "example-data-disk"
      disk_resource_group = "example-data-rg"
      backup_policy_name  = "daily"
    }
  ]

  tags_from_rg = false
  tags = {
    example = "basic"
  }
}
