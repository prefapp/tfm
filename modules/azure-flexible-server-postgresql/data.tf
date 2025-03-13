# Locals section
locals {
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
  vnet_from_data = can(data.azurerm_resources.vnet_from_tags[0].resources) ? data.azurerm_resources.vnet_from_tags[0].resources[0].name : null
  vnet_resource_group_from_data = can(data.azurerm_resources.vnet_from_tags[0].resources) ? data.azurerm_resources.vnet_from_tags[0].resources[0].resource_group_name : null
  resource_group_name  = var.postgresql_flexible_server.public_network_access_enabled == false ? try(coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data), null) : null
  virtual_network_name = var.postgresql_flexible_server.public_network_access_enabled == false ? try(coalesce(var.vnet.name, local.vnet_from_data), null) : null
  key_vault_id_from_data = can(data.azurerm_resources.key_vault_from_tags[0].resources) ? data.azurerm_resources.key_vault_from_tags[0].resources[0].id : null
}

# Data section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_resources" "vnet_from_name" {
  type = "Microsoft.Network/virtualNetworks"
  name                = var.vnet.name
  resource_group_name = var.vnet.resource_group_name
}

data "azurerm_resources" "vnet_from_tags" {
  count = length(var.vnet_tags) > 0 ? 1 : 0
  type = "Microsoft.Network/virtualNetworks"
  required_tags = var.vnet_tags
}

data "azurerm_subnet" "subnet" {
  count = var.subnet.name != null && var.subnet.name != "" ? 1 : 0
  name                 = var.subnet.name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data)
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone
data "azurerm_private_dns_zone" "dns_private_zone" {
  count = var.dns_private_zone_name != null && var.dns_private_zone_name != "" ? 1 : 0
  name                = var.dns_private_zone_name
  resource_group_name = coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data)
}


data "azurerm_resources" "key_vault_from_name" {
  type = "Microsoft.KeyVault/vaults"
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

data "azurerm_resources" "key_vault_from_tags" {
  count = length(var.key_vault_tags) > 0 ? 1 : 0
  type = "Microsoft.KeyVault/vaults"
  required_tags = var.key_vault_tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets
data "azurerm_key_vault_secret" "administrator_password" {
  count        = var.administrator_password_key_vault_secret_name != null && var.administrator_password_key_vault_secret_name != "" ? 1 : 0
  name         = var.administrator_password_key_vault_secret_name
  key_vault_id = coalesce(data.key_vault.key_vault_from_name.id, local.key_vault_id_from_data)
}
