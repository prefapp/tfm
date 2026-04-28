# Two map entries are illustrative only (name vs id, RG vs resource scope); use one key or {} if you prefer.
# `foo` sets principal type explicitly; `bar` omits `type` and uses the module default (ServicePrincipal).
# Replace scope, principal ID, and role with values from your tenant.
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
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup"
      role_definition_name = "Reader"
      target_id            = "00000000-0000-0000-0000-000000000000"
      type                 = "ServicePrincipal"
    }
    bar = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM"
      role_definition_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/12345678-1234-1234-1234-123456789012"
      target_id            = "00000000-0000-0000-0000-000000000001"
    }
  }
}
