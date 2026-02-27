## VPN NAT RULE SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_nat_rule
resource "azurerm_virtual_network_gateway_nat_rule" "this" {
  for_each = { for idx, rule in var.nat_rules : idx => rule }
  name                       = each.value.name
  resource_group_name        = var.vpn.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  mode                       = each.value.mode
  type                       = each.value.type
  ip_configuration_id        = azurerm_virtual_network_gateway.this.ip_configuration[0].id

  external_mapping {
    address_space = each.value.external_mapping_address_space
  }

  internal_mapping {
    address_space = each.value.internal_mapping_address_space
  }
}
