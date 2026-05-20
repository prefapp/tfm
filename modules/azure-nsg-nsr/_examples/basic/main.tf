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

module "nsg" {
  source = "../.."

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  nsg = {
    name                = "example-nsg"
    location            = "westeurope"
    resource_group_name = "example-rg"
  }

  rules = {
    ssh = {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/24"
      destination_address_prefix = "*"
    }
    http = {
      name                       = "AllowHTTP"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "0.0.0.0/0"
      destination_address_prefix = "*"
    }
  }
}
