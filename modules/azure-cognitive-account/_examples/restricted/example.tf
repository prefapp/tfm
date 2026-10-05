# Fictitious values for terraform validate; replace before apply.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.66.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "cognitive_account" {
  source = "../.."

  name                  = "example-openai-restricted"
  location              = "westeurope"
  resource_group_name   = "example-ai-rg"
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "example-openai-restricted"

  dynamic_throttling_enabled         = null
  local_auth_enabled                 = false
  public_network_access_enabled      = true
  outbound_network_access_restricted = false
  project_management_enabled         = false

  network_acls = {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = []
    virtual_network_rules = [
      {
        subnet_id                            = "/subscriptions/<subscription-id>/resourceGroups/<network-resource-group>/providers/Microsoft.Network/virtualNetworks/<virtual-network>/subnets/<subnet>"
        ignore_missing_vnet_service_endpoint = false
      }
    ]
  }

  tags_from_rg = true
  tags = {
    application = "example"
  }
}
