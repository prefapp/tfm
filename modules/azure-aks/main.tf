terraform {
  required_version = ">= 1.7.1"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}
