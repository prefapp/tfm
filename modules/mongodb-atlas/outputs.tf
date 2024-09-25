# Users section
# Local values to filter the key vault secrets
locals {
  # Filter the key vault secrets to only include those that match the pattern for the generated passwords
  names = [for secret in data.azurerm_key_vault_secrets.key_vault_secrets.secrets : secret.name if can(regex("test-${var.provider.provider_name}-.*", secret.name))]
}

# Output the filtered key vault secrets
output "key_vault_secrets_passwords" {
  value = local.names
}

# Datadog API Key section
# Output datadog secret name
output "datadog_secret_name" {
  value = var.enabled_datadog_integration ? azurerm_key_vault_secret.datadog_api_key_secrets[0].name : null
}
