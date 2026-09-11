#Locals section
locals {
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags

  # Per-endpoint vnet resolution: explicit name/resource_group_name wins, otherwise resolved from tags.
  vnet_resolved = {
    for k, v in var.private_endpoints : k => {
      name                = coalesce(try(data.azurerm_resources.vnet_from_name[k].resources[0].name, null), try(data.azurerm_resources.vnet_from_tags[k].resources[0].name, null), v.vnet.name)
      resource_group_name = coalesce(try(data.azurerm_resources.vnet_from_name[k].resources[0].resource_group_name, null), try(data.azurerm_resources.vnet_from_tags[k].resources[0].resource_group_name, null), v.vnet.resource_group_name)
    }
  }

  # Private DNS zone id per endpoint: explicit private_dns_zone_id wins, otherwise resolved via data source.
  private_dns_zone_ids = {
    for k, v in var.private_endpoints : k => try(trimspace(v.private_dns_zone_id), "") != "" ? trimspace(v.private_dns_zone_id) : try(data.azurerm_private_dns_zone.dns_private_zone[k].id, null)
  }
}

#Data Section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources
data "azurerm_resources" "vnet_from_name" {
  for_each            = { for k, v in var.private_endpoints : k => v if try(trimspace(v.vnet.name), "") != "" && try(trimspace(v.vnet.resource_group_name), "") != "" }
  type                = "Microsoft.Network/virtualNetworks"
  name                = trimspace(each.value.vnet.name)
  resource_group_name = trimspace(each.value.vnet.resource_group_name)
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
  for_each            = { for k, v in var.private_endpoints : k => v if try(trimspace(v.private_dns_zone_id), "") == "" }
  name                = trimspace(each.value.dns_private_zone_name)
  resource_group_name = try(trimspace(each.value.dns_private_zone_resource_group), "") != "" ? trimspace(each.value.dns_private_zone_resource_group) : local.vnet_resolved[each.key].resource_group_name
}
