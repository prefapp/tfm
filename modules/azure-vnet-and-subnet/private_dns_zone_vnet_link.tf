# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.private_dns_zone_virtual_network_links
  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.private_dns_zone_name].name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
}
