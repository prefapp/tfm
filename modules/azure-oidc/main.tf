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

# app_registrations:
#   - name: service_repositories
#     roles:
#       - AcrPush
#       - AcrPull
#     scope:
#       - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registries"
#       - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/bar/providers/Microsoft.ContainerRegistry/registries/bar-registries"
#     federated_credentials:
#       - subject: "repository_owner:prefapp"
#         issuer: "https://token.actions.githubusercontent.com"
#   - name: state_repositorie
#     roles:
#       - AcrPush
#     scope:
#       - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/foo/providers/Microsoft.ContainerRegistry/registries/foo-registries"
#     federated_credentials:
#       - subject: "repository_owner:prefapp"
#         issuer: "https://token.actions.githubusercontent.com"
#   - name: infra_repositorie
#     roles:
#       - Contributor
#     federated_credentials:
#       - subject: "my_repo_foo"
#         issuer: "issuer_foo"
#       - subject: "my_repo_bar"
#         issuer: "issuer_bar"
#     # scope:
#     #   - "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # This is similar to not putting scope

resource "azurerm_role_assignment" "gh_oidc_service_role_assignment" {
  for_each             = { 
    for item in flatten ([
      for app in var.data.applications : [
        for role in app.roles : [
          for scope in lookup(app, "scope", [data.azurerm_subscription.primary.id]) : {
            app_name = app.name
            role_name = role
            app_scope = scope
          }
        ]
      ]
    ]) : format("%s-%s-%s", item.app_name, item.role_name, item.app_scope) => item
  }
  scope                = each.value.app_scope
  role_definition_name = each.value.role_name
  principal_id         = azuread_service_principal.gh_oidc_service_principal[each.value.app_name].id
}

# resource "azuread_application_federated_identity_credential" "gh_oidc_identity_credential" {
#   for_each              = { for app in var.data.applications : app.name => app }
#   application_object_id = azuread_application.gh_oidc_ad_app[each.value.name].object_id
#   display_name          = "oidc_identity_credential"
#   description           = var.data.subject
#   audiences             = ["api://AzureADTokenExchange"]
#   issuer                = "https://token.actions.githubusercontent.com"
#   subject               = var.data.subject
# }

resource "azuread_application_federated_identity_credential" "gh_oidc_identity_credential" {
  for_each = {
    for item in flatten ([
      for app in var.data.applications : [
        for cred in lookup(app, "federated_credentials", []) : {
          app_name = app.name
          cred = cred
        }
      ]
    ]) : format("%s-%s", item.app_name, item.cred.subject) => item
  }
  application_object_id = azuread_application.gh_oidc_ad_app[each.value.app_name].object_id
  # displayname debe ser único y no contener caracter : reemplzar por espacio
  display_name          = replace(format("oidc_identity_credential - %s", each.value.cred.subject), ":", " ")
  description           = "oidc_identity_credential - ${each.value.cred.subject}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = each.value.cred.issuer
  subject               = each.value.cred.subject
}
