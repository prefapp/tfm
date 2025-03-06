resource "azurerm_private_dns_zone" "this" {
  for_each            = { for zone in var.private_dns_zones : zone.name => zone }
  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}
