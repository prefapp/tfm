terraform {
  required_version = ">= 1.7.0"
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.23.0, < 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0, < 5.0.0"
    }
  }
}
