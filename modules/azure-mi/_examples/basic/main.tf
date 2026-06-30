# Replace resource_group, location, and name with values valid in your subscription.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "managed_identity" {
  source = "../.."

  name           = "uami-basicex01"
  resource_group = "example-rg"
  location       = "westeurope"

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  rbac                  = []
  federated_credentials = []
  access_policies       = []
}

output "principal_id" {
  description = "Object ID of the managed identity (common input for RBAC elsewhere)."
  value       = module.managed_identity.principal_id
}
