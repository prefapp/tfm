terraform {
  required_version = ">= 1.7.1"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}
