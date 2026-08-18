locals {
  existing_private_dns_zone_links = {
    for link in var.existing_private_dns_zone_links :
    "${coalesce(link.resource_group_name, var.resource_group_name)}-${link.private_dns_zone_name}-${link.name}" => merge(link, {
      resource_group_name = coalesce(link.resource_group_name, var.resource_group_name)
    })
  }
}

data "azurerm_private_dns_zone" "existing" {
  for_each = local.existing_private_dns_zone_links

  name                = each.value.private_dns_zone_name
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "existing" {
  for_each = local.existing_private_dns_zone_links

  name                  = each.value.name
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.existing[each.key].name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
}