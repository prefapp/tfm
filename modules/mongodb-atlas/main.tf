terraform {
  required_version = ">= 1.7.1"
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.20.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "3.44.1"
    }
  }
}
