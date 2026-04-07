# Replace scope, principal ID, and role with values from your tenant.

terraform {
  required_version = ">= 1.7.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_role_assignment" {
  source = "../.."

  role_assignments = {
    example = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg"
      role_definition_name = "Reader"
      target_id            = "00000000-0000-0000-0000-000000000000"
      type                 = "ServicePrincipal"
    }
  }
}
