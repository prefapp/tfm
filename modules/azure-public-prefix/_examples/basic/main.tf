# Replace names, region, and prefix sizing for your subscription.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.16.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "public_ip_prefix" {
  source = "../.."

  name                = "example-prefix"
  resource_group_name = "example-rg"
  location            = "westeurope"

  sku       = "Standard"
  sku_tier  = "Regional"
  ip_version = "IPv4"

  prefix_length = 29
  zones         = ["1"]

  tags_from_rg = false
  tags = {
    example = "basic"
  }
}
