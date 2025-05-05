terraform {
  required_version = ">= 1.7.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
}
