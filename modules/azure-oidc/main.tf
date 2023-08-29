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
  for_each     = { for app in var.data.applications : app.name => app }
  display_name = "GitHub OIDC Management - ${each.value.name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "gh_oidc_service_principal" {
  for_each     = azuread_application.gh_oidc_ad_app
  application_id = each.value.application_id
}

resource "azurerm_role_assignment" "gh_oidc_service_role_assignment" {
  for_each             = { for app in var.data.applications : app.name => app }
  scope                = join("", [data.azurerm_subscription.primary.id, each.value.scopes[0]])
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.gh_oidc_service_principal[each.key].object_id
}

resource "azuread_application_federated_identity_credential" "gh_oidc_identity_credential" {
  for_each              = var.data.applications
  application_object_id = azuread_application.gh_oidc_ad_app[each.value.name].object_id
  display_name          = "gh_oidc_identity_credential"
  description           = "Github OIDC Identity Credential"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = each.value.name
}
