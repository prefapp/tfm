terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.3.0"
    }

  }
}
