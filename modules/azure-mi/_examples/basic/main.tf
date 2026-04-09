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
}

module "managed_identity" {
  source = "../.."

  name           = "example-mi"
  resource_group = "example-rg"
  location       = "westeurope"

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  rbac = [
    {
      name  = "subscription-reader"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
      roles = ["Reader"]
    }
  ]

  federated_credentials = []
  access_policies       = []
}
