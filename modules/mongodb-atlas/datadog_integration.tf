# Datadog API Key section
# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/api_key
resource "datadog_api_key" "datadog_api_key" {
  name = var.datadog_api_key_name
}

# Datadog API Key data source
# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/data-sources/api_key
data "datadog_api_key" "datadog_api_key_data" {
  count = var.enabled_datadog_integration ? 1 : 0
  name  = var.datadog_api_key_name

  # Ensure data source is fetched after the API key is created
  depends_on = [datadog_api_key.datadog_api_key]
}

# Store the Datadog API key in Azure Key Vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "datadog_api_key_secrets" {
  count        = var.enabled_datadog_integration ? 1 : 0
  name         = var.datadog_api_key_name
  value        = data.datadog_api_key.datadog_api_key_data[0].key
  key_vault_id = data.azurerm_key_vault.key_vault.id

  # Ensure secret is created after the Datadog API key data source
  depends_on = [datadog_api_key.datadog_api_key]
}

# MongoDB Atlas Third Party Integration for Datadog
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/third_party_integration
resource "mongodbatlas_third_party_integration" "test_datadog" {
  count      = var.enabled_datadog_integration ? 1 : 0
  project_id = mongodbatlas_project.project.id
  type       = "DATADOG"
  api_key    = azurerm_key_vault_secret.datadog_api_key_secrets[0].value
  region     = var.mongo_region

  # Ensure integration is created after the Datadog API key
  depends_on = [datadog_api_key.datadog_api_key]
}
