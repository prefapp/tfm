# Same role_assignments shape as _examples/comprehensive; replace IDs and paths with values from your tenant.

terraform {
  required_version = ">= 1.7.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_role_assignment" {
  source = "../.."

  role_assignments = {
    foo = {
      scope                = "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/resourceGroups/myResourceGroup"
      role_definition_name = "Reader"
      target_id            = "12345678-1234-1234-1234-123456789012"
    }
    bar = {
      scope                = "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM"
      role_definition_id   = "/subscriptions/424f653a-bb14-441f-bc4a-6c4f3409cb41/providers/Microsoft.Authorization/roleDefinitions/12345678-1234-1234-1234-123456789012"
      target_id            = "87654321-4321-4321-4321-210987654321"
    }
  }
}
