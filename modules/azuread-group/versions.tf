terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.52.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.16.0"
    }
  }
}
