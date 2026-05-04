# Fictitious values for terraform validate; replace before apply.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.51.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "event_hub" {
  source = "../.."

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  namespace = {
    name                 = "ehns-example-basic"
    location             = "westeurope"
    resource_group_name  = "example-rg"
    sku                  = "Standard"
    capacity             = 1
    auto_inflate_enabled = false
    identity_type        = "SystemAssigned"
    ruleset = {
      default_action                 = "Allow"
      public_network_access_enabled  = true
      trusted_service_access_enabled = true
      virtual_network_rules          = []
      ip_rules                       = []
    }
  }

  system_topic = {}

  eventhub = {
    hub1 = {
      name                 = "events"
      partition_count      = 2
      message_retention    = 1
      consumer_group_names = ["cg1"]
      auth_rules = [
        {
          name   = "listen"
          listen = true
          send   = false
          manage = false
        }
      ]
    }
  }
}
