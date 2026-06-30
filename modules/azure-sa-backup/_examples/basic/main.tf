# File-share backup path only. Replace backup RG, storage account ID, vault/share names.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "storage_backup" {
  source = "../.."

  backup_resource_group_name = "example-backup-rg"
  storage_account_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Storage/storageAccounts/stexample"

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  backup_share = {
    policy_name                  = "daily-policy"
    recovery_services_vault_name = "example-rsvault"
    sku                          = "Standard"
    source_file_share_name       = ["example-share"]
    timezone                     = "UTC"
    backup = {
      frequency = "Daily"
      time      = "02:00"
    }
    retention_daily = {
      count = 7
    }
  }

  backup_blob           = null
  lifecycle_policy_rule = null
}
