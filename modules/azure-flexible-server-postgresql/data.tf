# Locals section
locals {
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
  virtual_network_name = coalesce(var.vnet.vnet_name, data.azurerm_resources.vnet.resources[0].name)
  resource_group_name  = coalesce(var.vnet.vnet_resource_group, data.azurerm_resources.vnet.resources[0].resource_group_name)
}

# Data section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

data "azurerm_resource_group" "vnet" {
  name                = var.vnet.vnet_name
  resource_group_name = var.vnet.vnet_resource_group
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
  type = "Microsoft.Network/virtualNetworks"
  required_tags = {
    tenant = "${data.azurerm_resource_group.resource_group.tags.tenant}"
    env    = "${data.azurerm_resource_group.resource_group.tags.env}"
  }
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
