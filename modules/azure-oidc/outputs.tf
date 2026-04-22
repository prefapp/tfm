output "application_id" {
  description = "Map of application names to Entra application (client) IDs."
  value       = { for k, v in azuread_application.gh_oidc_ad_app : k => v.application_id }
}

output "service_principal_id" {
  description = "Map of application names to service principal object IDs (RBAC `principal_id`)."
  value       = { for k, v in azuread_service_principal.gh_oidc_service_principal : k => v.id }
}
