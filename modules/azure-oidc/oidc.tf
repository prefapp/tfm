# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "gh_oidc_ad_app" {
  for_each     = { for app in var.data.applications : app.name => app }
  display_name = "GitHub OIDC Management - ${each.value.name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "gh_oidc_service_principal" {
  for_each     = azuread_application.gh_oidc_ad_app
  application_id = each.value.application_id
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential
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
  display_name          = "oidc_identity_credential-${each.value.cred.subject}"
  description           = "oidc_identity_credential - ${each.value.cred.subject}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = each.value.cred.issuer
  subject               = each.value.cred.subject
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
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
