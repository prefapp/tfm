output "application_id" {
  description = "Map of application names to Entra application (client) IDs."
  value       = { for k, v in azuread_application.gh_oidc_ad_app : k => v.application_id }
}

output "service_principal_id" {
  description = "Map of application names to service principal object IDs (RBAC `principal_id`)."
  value       = { for k, v in azuread_service_principal.gh_oidc_service_principal : k => v.id }
}

output "applications" {
  description = "Map of applications with application_id and object_id."
  value = {
    for k, v in azuread_application.gh_oidc_ad_app : k => {
      application_id = v.application_id
      object_id = v.object_id
    }
  }
}

output "service_principals" {
  description = "Map of service principals with object_id (principal_id)."
  value = {
    for k, v in azuread_service_principal.gh_oidc_service_principal : k => {
      object_id    = v.id
      display_name = v.display_name
    }
  }
}

output "role_assignments" {
  description = "Map of role assignments keyed by app-role-scope."
  value = {
    for k, v in azurerm_role_assignment.gh_oidc_service_role_assignment : k => {
      id           = v.id
      scope        = v.scope
      role_name    = v.role_definition_name
      principal_id = v.principal_id
    }
  }
}
