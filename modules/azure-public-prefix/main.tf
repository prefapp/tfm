# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix
resource "azurerm_public_ip_prefix" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  sku_tier            = var.sku_tier
  ip_version          = var.ip_version
  prefix_length       = var.prefix_length
  zones               = var.zones
  tags                = var.tags
}
