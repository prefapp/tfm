# Illustrative policies only — adjust names, rules, and scope for your tenant.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.22.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "policy_definitions" {
  source = "../.."

  policies = [
    {
      name         = "example-audit-location"
      policy_type  = "Custom"
      mode         = "All"
      display_name = "Example Policy"
      description  = "Sample policy to audit location."
      policy_rule = jsonencode({
        if = {
          field  = "location"
          equals = "westeurope"
        }
        then = {
          effect = "audit"
        }
      })
      metadata   = "{}"
      parameters = "{}"
    }
  ]
}
