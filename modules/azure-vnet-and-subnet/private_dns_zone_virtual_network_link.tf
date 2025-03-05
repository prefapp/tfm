# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.private_dns_zone_virtual_network_links
  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.private_dns_zone_name
  virtual_network_id    = module.network.vnet_id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
  depends_on = [
    azurerm_private_dns_zone.this
  ]
}
