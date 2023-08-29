terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.0.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }

  }
}

provider "azurerm" {
  features {}
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "primary" {}


resource "azuread_application" "gh_oidc_ad_app" {
  display_name = "GitHub OIDC Management - ${var.application}"
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "gh_oidc_service_principal" {
  application_id = azuread_application.gh_oidc_ad_app.application_id
}

resource "azurerm_role_assignment" "gh_oidc_service_role_assignment" {
  scope = join("", [data.azurerm_subscription.primary.id, "/resourceGroups/cbx-acr/providers/Microsoft.ContainerRegistry/registries/cbxacr"])
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.gh_oidc_service_principal.object_id
}

resource "azuread_application_federated_identity_credential" "gh_oidc_identity_credential" {
  for_each              = toset(var.subs)
  application_object_id = azuread_application.gh_oidc_ad_app.object_id
  display_name          = "gh_oidc_identity_credential"
  description           = "Github OIDC Identity Credential"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "${each.key}"
}
