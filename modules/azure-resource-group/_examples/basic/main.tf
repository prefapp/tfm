# Minimal example: replace name, location, and subscription as needed.

terraform {
  required_version = ">= 1.7.0"

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

module "resource_group" {
  source = "../.."

  name     = "example-rg"
  location = "westeurope"
  tags = {
    example = "basic"
  }
}
