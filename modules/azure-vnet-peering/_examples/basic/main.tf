# Both virtual networks and resource groups must exist before apply.
# Replace names with values from your subscription.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.85.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_vnet_peering" {
  source = "../.."

  origin_virtual_network_name = "origin-vnet"
  origin_resource_group_name  = "example-rg"
  origin_name_peering         = "origin-to-destination"

  destination_virtual_network_name = "destination-vnet"
  destination_resource_group_name  = "example-rg"
  destination_name_peering         = "destination-to-origin"
}
