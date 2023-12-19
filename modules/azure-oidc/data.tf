# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config
data "azuread_client_config" "current" {}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription
data "azurerm_subscription" "primary" {}
