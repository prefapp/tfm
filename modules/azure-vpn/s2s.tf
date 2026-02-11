## S2S VPN SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway
resource "azurerm_local_network_gateway" "this" {
	for_each            = { for idx, s in var.s2s : idx => s }
	name                = each.value.local_gateway_name
	location            = var.vpn.location
	resource_group_name = var.vpn.resource_group_name
	gateway_address     = each.value.local_gateway_ip
	address_space       = each.value.local_gateway_address_space
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection
resource "azurerm_virtual_network_gateway_connection" "this" {
	for_each                   = { for idx, s in var.s2s : idx => s }
	name                       = each.value.connection_name
	location                   = var.vpn.location
	resource_group_name        = var.vpn.resource_group_name
  type                       = var.s2s[0].type
	virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
	local_network_gateway_id   = azurerm_local_network_gateway.this[each.key].id
	shared_key                 = each.value.shared_key
	enable_bgp                 = each.value.enable_bgp
}
