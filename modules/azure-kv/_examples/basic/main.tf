# Basic example: Key Vault with access policy by object_id

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

module "azure_kv" {
  source = "../.."

  name                        = "examplekv001"
  resource_group              = "example-rg"
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = false

  access_policies = [
    {
      name                    = "example-principal"
      object_id               = "00000000-0000-0000-0000-000000000000"
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List", "Set"]
      certificate_permissions = []
      storage_permissions     = []
    }
  ]

  tags_from_rg = false
  tags = {
    environment = "dev"
    application = "example"
  }
}
