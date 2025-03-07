# Locals section
locals {
  vnet_from_data = length(data.azurerm_resources.vnet) > 0 && length(data.azurerm_resources.vnet[0].resources) > 0 ? data.azurerm_resources.vnet[0].resources[0].name : null
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
  virtual_network_name = coalesce(var.vnet.name, local.vnet_from_data)
  resource_group_name  = coalesce(var.vnet.resource_group_name, try(data.azurerm_resources.vnet[0].resources[0].resource_group_name))
}

# Data section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "vnet" {
  count               = var.vnet.name != null && var.vnet.resource_group_name != "" ? 1 : 0
  name                = var.vnet.name
  resource_group_name = var.vnet.resource_group_name
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "subnet" {
  name                 = var.subnet.name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = local.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone
data "azurerm_private_dns_zone" "dns_private_zone" {
  name                = var.dns_private_zone.name
  resource_group_name = local.resource_group_name
}

data "azurerm_resources" "vnet" {
  count = length(var.vnet_tags) > 0 ? 1 : 0
  type = "Microsoft.Network/virtualNetworks"
  required_tags = var.vnet_tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault
data "azurerm_key_vault" "key_vault" {
  count               = var.key_vault != null && var.key_vault.name != "" && var.key_vault.resource_group_name != "" ? 1 : 0
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets
data "azurerm_key_vault_secret" "administrator_password" {
  count        = var.administrator_password_key_vault_secret_name != null && var.administrator_password_key_vault_secret_name != "" ? 1 : 0
  name         = var.administrator_password_key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
}
