# RESOURCES SECTION
# https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_group
resource "azurerm_network_security_group" "this" {
  name                = var.nsg.name
  location            = var.nsg.location
  resource_group_name = var.nsg.resource_group_name
  tags                = var.nsg.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/network_security_rule
resource "azurerm_network_security_rule" "this" {
  for_each                     = var.rules
  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  resource_group_name          = var.nsg.resource_group_name
  network_security_group_name  = var.nsg.name
}
