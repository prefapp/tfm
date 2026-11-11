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

  name                  = "example-openai"
  location              = "westeurope"
  resource_group_name   = "example-ai-rg"
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "example-openai"

  dynamic_throttling_enabled         = null
  local_auth_enabled                 = true
  public_network_access_enabled      = true
  outbound_network_access_restricted = false
  project_management_enabled         = false

  network_acls = {
    bypass                = "AzureServices"
    default_action        = "Allow"
    ip_rules              = []
    virtual_network_rules = []
  }

  tags_from_rg = false
  tags = {
    application = "example"
    environment = "test"
  }
}
