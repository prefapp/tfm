## DATA SECTION

data "azurerm_client_config" "current" {}

# Use data resources to get the Azure Apps UUIDs so we can address them by name
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# RESOURCES SECTION

## Azure AD Application

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "this" {
  display_name = var.name

  group_membership_claims = ["ApplicationGroup"]

  api {
    requested_access_token_version = 2
  }

  dynamic "required_resource_access" {
    for_each = length(var.msgraph_roles) > 0 ? [1] : []

    content {
      resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

      dynamic "resource_access" {
        for_each = var.msgraph_roles
        iterator = role
        content {
          id   = lookup(data.azuread_service_principal.msgraph.app_role_ids, role.value, null)
          type = "Scope"
        }

      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_redirect_uris
resource "azuread_application_redirect_uris" "this" {
  for_each       = { for idx, redirect in var.redirects : idx => redirect }
  application_id = azuread_application.this.id
  type           = each.value.platform
  redirect_uris  = each.value.redirect_uris
}

## Azure Enterprise Application

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "this" {
  client_id    = azuread_application.this.client_id
  use_existing = true
}

## Client Secret Management

resource "time_rotating" "this" {
  count         = var.client_secret.enabled ? 1 : 0
  rotation_days = var.client_secret.rotation_days
}

resource "azuread_application_password" "this" {
  count          = var.client_secret.enabled ? 1 : 0
  application_id = azuread_application.this.id
  rotate_when_changed = {
    rotation = time_rotating.this[0].id
  }
}

resource "azurerm_key_vault_secret" "this" {
  count        = (var.client_secret.keyvault != null && var.client_secret.enabled) ? 1 : 0
  key_vault_id = var.client_secret.keyvault.id
  name         = var.client_secret.keyvault.key_name
  value        = azuread_application_password.this[0].value
}


## Application Group and User Membership

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "members" {
  for_each = toset(var.members)
  # Default Access role ID
  app_role_id         = "00000000-0000-0000-0000-000000000000"
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}

## Application MSGraph Roles

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "msgraph_roles" {
  for_each            = toset(var.msgraph_roles)
  depends_on          = [azuread_service_principal.this]
  principal_object_id = azuread_service_principal.this.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
  app_role_id         = lookup(data.azuread_service_principal.msgraph.app_role_ids, each.value, null)

}

## Federated Identity Credential
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential

resource "azuread_application_federated_identity_credential" "this" {
  for_each       = { for idx, cred in var.federated_credentials : idx => cred }
  application_id = azuread_application.this.id
  audiences      = each.value.audiences
  issuer         = each.value.issuer
  subject        = each.value.subject
  description    = each.value.description
  display_name   = each.value.display_name
}


# Extra role assignments
resource "azurerm_role_assignment" "extra_role_assignments" {
  for_each             = { for idx, assignment in var.extra_role_assignments : idx => assignment }
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_service_principal.this.id
}
