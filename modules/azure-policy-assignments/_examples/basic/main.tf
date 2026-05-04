# Replace policy display names and provider context for your tenant.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.22.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "policy_assignments" {
  source = "../.."

  assignments = [
    {
      name        = "example-allowed-locations"
      policy_type = "builtin"
      policy_name = "Allowed locations"
      scope       = "subscription"
    }
  ]
}
