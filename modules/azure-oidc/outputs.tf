# AZURE_CLIENT_ID
output "oidc_azure_client_id" {
  value = azuread_application.gh_oidc_ad_app.application_id
}

# AZURE_SUBSCRIPTION_ID
output "oidc_azure_subscription_id" {
  value = data.azurerm_subscription.primary.id
}

# AZURE_TENAND_ID
output "oidc_azure_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}
