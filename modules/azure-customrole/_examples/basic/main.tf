# Minimal example: set subscription_id (see README) and ensure you can create role definitions.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

module "custom_role" {
  source = "../.."

  name = "example-custom-disk-reader"

  assignable_scopes = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]

  permissions = {
    actions = [
      "Microsoft.Compute/disks/read",
    ]
  }
}
