# Replace resource_group with an existing RG name and name with a globally unique vault name (3–24 alphanumeric).

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

  name                        = "kv-basicex0001"
  resource_group              = "example-rg"
  enabled_for_disk_encryption = false
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  access_policies             = []

  tags_from_rg = false
  tags = {
    example = "basic"
  }
}

output "vault_uri" {
  value = module.key_vault.vault_uri
}
