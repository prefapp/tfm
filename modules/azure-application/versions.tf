terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0, < 5.0.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0, < 4.0.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.0, < 1.0.0"
    }
  }
}
