#Locals section
locals {
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags

  # Per-endpoint vnet resolution: explicit name/resource_group_name wins, otherwise resolved from tags.
  vnet_resolved = {
    for k, v in var.private_endpoints : k => {
      name                = try(coalesce(data.azurerm_resources.vnet_from_name[k].resources[0].name, data.azurerm_resources.vnet_from_tags[k].resources[0].name, v.vnet.name), null)
      resource_group_name = try(coalesce(data.azurerm_resources.vnet_from_name[k].resources[0].resource_group_name, data.azurerm_resources.vnet_from_tags[k].resources[0].resource_group_name, v.vnet.resource_group_name), null)
    }
  }

  # Private DNS zone id per endpoint: explicit private_dns_zone_id wins, otherwise resolved via data source.
  private_dns_zone_ids = {
    for k, v in var.private_endpoints : k => coalesce(v.private_dns_zone_id, try(data.azurerm_private_dns_zone.dns_private_zone[k].id, null))
  }
}

#Data Section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources
data "azurerm_resources" "vnet_from_name" {
  for_each          = { for k, v in var.private_endpoints : k => v if v.vnet.name != null && v.vnet.name != "" && v.vnet.resource_group_name != null && v.vnet.resource_group_name != "" }
  type              = "Microsoft.Network/virtualNetworks"
  name              = each.value.vnet.name
  resource_group_name = each.value.vnet.resource_group_name
}

data "azurerm_resources" "vnet_from_tags" {
  for_each      = { for k, v in var.private_endpoints : k => v if length(coalesce(v.vnet.tags, {})) > 0 }
  type          = "Microsoft.Network/virtualNetworks"
  required_tags = each.value.vnet.tags
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
data "azurerm_subnet" "subnet" {
  for_each             = var.private_endpoints
  name                 = each.value.subnet_name
  virtual_network_name = local.vnet_resolved[each.key].name
  resource_group_name  = local.vnet_resolved[each.key].resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone
# Only queried in-subscription when private_dns_zone_id was not provided directly.
data "azurerm_private_dns_zone" "dns_private_zone" {
  for_each            = { for k, v in var.private_endpoints : k => v if v.private_dns_zone_id == null }
  name                = each.value.dns_private_zone_name
  resource_group_name = coalesce(each.value.dns_private_zone_resource_group, local.vnet_resolved[each.key].resource_group_name)
}
