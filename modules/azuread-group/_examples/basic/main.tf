# Minimal example: empty members, owners, and role lists.
# Extend with real users, service principals, scopes, and directory roles for your tenant.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.52.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.16.0"
    }
  }
}

provider "azuread" {
  tenant_id = "00000000-0000-0000-0000-000000000000" # Replace with your tenant ID
}

provider "azurerm" {
  features {}
}

module "azuread_group" {
  source = "../.."

  name        = "example-terraform-group"
  description = "Minimal example; replace name and add members/roles as needed."

  members = []
  owners  = []

  subscription_roles = []
  directory_roles    = []

  enable_pim = false
}

output "group_id" {
  value = module.azuread_group.group_id
}
