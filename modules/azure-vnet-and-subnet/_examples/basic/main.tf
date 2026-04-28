# Minimal example: one VNet, one subnet, no private DNS zones or peerings.
# Adjust names and location for your subscription before apply.

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.21.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "example-rg-vnet-basic"
  location = "westeurope"
}

module "azure_vnet_and_subnet" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name

  virtual_network = {
    name          = "example-vnet"
    location      = azurerm_resource_group.this.location
    address_space = ["10.0.0.0/16"]
    subnets = {
      internal = {
        address_prefixes = ["10.0.1.0/24"]
      }
    }
  }

  private_dns_zones = []
  peerings          = []

  tags_from_rg = false
  tags = {
    environment = "dev"
    example     = "basic"
  }
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = module.azure_vnet_and_subnet.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs keyed as vnet_name.subnet_key"
  value       = module.azure_vnet_and_subnet.subnet_ids
}
