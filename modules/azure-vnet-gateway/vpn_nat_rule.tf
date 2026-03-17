## VPN NAT RULE SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_nat_rule
resource "azurerm_virtual_network_gateway_nat_rule" "this" {
  for_each                   = { for rule in var.nat_rules : rule.name => rule }
  name                       = each.value.name
  resource_group_name        = var.vpn.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  mode                       = each.value.mode
  type                       = each.value.type

  ip_configuration_id = try(
    each.value.ip_configuration_id,
    azurerm_virtual_network_gateway.this.ip_configuration[0].id
  )

  dynamic "external_mapping" {
    for_each = each.value.external_mapping
    content {
      address_space = external_mapping.value.address_space
      port_range    = external_mapping.value.port_range
    }
  }

  dynamic "internal_mapping" {
    for_each = each.value.internal_mapping
    content {
      address_space = internal_mapping.value.address_space
      port_range    = internal_mapping.value.port_range
    }
  }

  lifecycle {
    precondition {
      condition = (
        try(each.value.ip_configuration_id, null) != null ||
        length(azurerm_virtual_network_gateway.this.ip_configuration) > 0
      )
      error_message = "ip_configuration_id must be provided or derivable from the gateway"
    }
  }
}
