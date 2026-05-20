# Minimal example: replace names, location, and subscription as needed.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-disks-rg"
  location = "westeurope"
}

module "disks" {
  source = "../.."

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  disks = [
    { name = "disk-01", disk_size_gb = 32, storage_account_type = "StandardSSD_LRS" }
  ]

  assign_role  = false
  principal_id = ""

  tags_from_rg = false
  tags = {
    example = "basic"
  }
}
