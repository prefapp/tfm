# Minimal example: app registration with one Web redirect. Configure Entra ID auth (e.g. az login) and subscription_id.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {
  # tenant_id defaults from ARM_TENANT_ID / az cli when unset
}

module "application" {
  source = "../.."

  name = "example-terraform-app"

  redirects = [
    {
      platform      = "Web"
      redirect_uris = ["https://localhost:8080/auth"]
    }
  ]

  members       = []
  msgraph_roles = []

  client_secret = {
    enabled = false
  }

  federated_credentials  = []
  extra_role_assignments = []
}
