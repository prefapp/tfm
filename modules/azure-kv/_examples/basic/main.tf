# Minimal example: Key Vault with one access policy by object ID. Set subscription_id and real GUIDs before apply.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.21.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

resource "azurerm_resource_group" "example" {
  name     = "example-kv-rg"
  location = "westeurope"
}

module "key_vault" {
  source = "../.."

  name                        = "exkvtfm001"
  resource_group              = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = false

  access_policies = [
    {
      name                = "vault-admin"
      type                = ""
      object_id           = "00000000-0000-0000-0000-000000000000" # replace with a real object ID (e.g. your user or SP)
      key_permissions     = ["Get", "List"]
      secret_permissions  = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = []
    }
  ]

  tags_from_rg = false
  tags = {
    example = "basic"
  }
}
