terraform {
  required_version = ">= 1.7.1"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.52.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
  }
}
