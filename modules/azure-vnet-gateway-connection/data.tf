# Data source para local network gateway
data "azurerm_local_network_gateway" "this" {
	for_each = { for idx, s in var.connection : idx => s }
	name                = each.value.local_gateway_name
	resource_group_name = each.value.resource_group_name
}
## DATA SOURCES SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network

# Iterar sobre cada conexión para los data sources
data "azurerm_resource_group" "this" {
	for_each = { for idx, s in var.connection : idx => s }
	name     = each.value.resource_group_name
}

data "azurerm_virtual_network_gateway" "this" {
	for_each            = { for idx, s in var.connection : idx => s }
	name                = each.value.gateway_name
	resource_group_name = each.value.resource_group_name
}

# Optionally fetch shared_key from Key Vault if secret_name and vault info are provided
data "azurerm_key_vault_secret" "s2s" {
	for_each = { for idx, s in var.connection : idx => s if try(s.keyvault_secret_name, null) != null && try(s.keyvault_vault_name, null) != null && try(s.keyvault_vault_rg, null) != null }
	name         = each.value.keyvault_secret_name
	key_vault_id = data.azurerm_key_vault.s2s[each.key].id
}

data "azurerm_key_vault" "s2s" {
	for_each = { for idx, s in var.connection : idx => s if try(s.keyvault_vault_name, null) != null && try(s.keyvault_vault_rg, null) != null }
	name                = each.value.keyvault_vault_name
	resource_group_name = each.value.keyvault_vault_rg
}
