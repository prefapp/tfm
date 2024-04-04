# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
# Resource block for creating Azure network security groups
resource "azurerm_network_security_group" "nsg" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.network_security_group != null }

  name                = each.value.network_security_group.name
  location            = var.location
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = each.value.network_security_group.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
