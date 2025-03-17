#Locals section
locals {
    tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
    vnet_from_data                = can(data.azurerm_resources.vnet_from_tags[0].resources) ? data.azurerm_resources.vnet_from_tags[0].resources[0].name : null
    vnet_resource_group_from_data = can(data.azurerm_resources.vnet_from_tags[0].resources) ? data.azurerm_resources.vnet_from_tags[0].resources[0].resource_group_name : null
    resource_group_name           = try(coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data), null) : null
    virtual_network_name          = try(coalesce(var.vnet.name, local.vnet_from_data), null) : null
}

#Data Section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources
data "azurerm_resources" "vnet_from_name" {
  type                = "Microsoft.Network/virtualNetworks"
  name                = var.vnet.name
  resource_group_name = var.vnet.resource_group_name
}

data "azurerm_resources" "vnet_from_tags" {
  count         = length(coalesce(var.vnet.tags, {})) > 0 ? 1 : 0
  type          = "Microsoft.Network/virtualNetworks"
  required_tags = var.vnet.tags
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
data "azurerm_subnet" "subnet" {
  count                = var.subnet_name != null && var.subnet_name != "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone
data "azurerm_private_dns_zone" "dns_private_zone" {
  count               = var.dns_private_zone_name != null && var.dns_private_zone_name != "" ? 1 : 0
  name                = var.dns_private_zone_name
  resource_group_name = coalesce(var.vnet.resource_group_name, local.vnet_resource_group_from_data)
}
