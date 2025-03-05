# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone
resource "azurerm_private_dns_zone" "this" {
  for_each            = { for idx, zone in var.private_dns_zones : idx => zone }
  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = var.tags_from_rg ? data.azurerm_resource_group.resource_group.tags : var.tags
}
