terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.47.0, < 5.0.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 2.3, < 3.0.0"
    }
  }
}
