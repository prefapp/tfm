# Minimal example: empty members and msgraph_roles, one Web redirect.
# Replace tenant, redirect URIs, and add real object IDs / permissions for your environment.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
  }
}

provider "azuread" {
  tenant_id = "00000000-0000-0000-0000-000000000000" # Replace with your tenant ID
}

provider "azurerm" {
  features {}
}

module "azure_application" {
  source = "../.."

  name = "example-terraform-app"

  redirects = [
    {
      platform      = "Web"
      redirect_uris = ["https://localhost/signin-oidc"]
    }
  ]

  members       = []
  msgraph_roles = []
}

output "application_client_id" {
  value = module.azure_application.application_client_id
}
