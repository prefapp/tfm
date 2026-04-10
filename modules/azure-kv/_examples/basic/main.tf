# Replace names, IDs, and permissions with values valid in your tenant.
# The resource group must already exist. Key Vault names are globally unique.

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
}

provider "azuread" {}

module "key_vault" {
  source = "../.."

  name                        = "example-kv-basic-001"
  resource_group              = "example-rg"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = false

  access_policies = [
    {
      name                    = "example-direct-object-id"
      type                    = ""
      object_id               = "00000000-0000-0000-0000-000000000000"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
      storage_permissions     = []
    }
  ]

  tags_from_rg = false
  tags = {
    example = "basic"
  }
}
