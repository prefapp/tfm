# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link
locals {
  dns_zone_links = flatten([
    for zone in var.private_dns_zones : (
      zone.virtual_network_links != null ? [
        for vnet_link in zone.virtual_network_links : {
          dns_zone_name         = zone.name
          name                  = vnet_link.name
          virtual_network_id    = vnet_link.virtual_network_id
          registration_enabled  = zone.auto_registration_enabled
          virtual_network_name  = coalesce(vnet_link.virtual_network_name, vnet_link.name)
        }
      ] : [{
        dns_zone_name         = zone.name
        name                  = coalesce(zone.link_name, zone.name)
        virtual_network_id    = azurerm_virtual_network.this.id
        registration_enabled  = zone.auto_registration_enabled
        virtual_network_name  = coalesce(zone.link_name, zone.name)
      }]
    )
  ])
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = { for idx, link in local.dns_zone_links : "${link.dns_zone_name}-${link.name}" => link }
  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.dns_zone_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
}
