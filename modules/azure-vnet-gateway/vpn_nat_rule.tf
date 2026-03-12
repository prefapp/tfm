## VPN NAT RULE SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_nat_rule
resource "azurerm_virtual_network_gateway_nat_rule" "this" {
  for_each                   = { for rule in var.nat_rules : rule.name => rule }
  name                       = each.value.name
  resource_group_name        = var.vpn.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  mode                       = each.value.mode
  type                       = each.value.type
  ip_configuration_id = coalesce(
    try(each.value.ip_configuration_id, null),
    try(data.azurerm_virtual_network_gateway.this.ip_configuration[0].id, null)
  )

  external_mapping {
    address_space = each.value.external_mapping_address_space
  }

  internal_mapping {
    address_space = each.value.internal_mapping_address_space
  }
}
