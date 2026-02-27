## LOCAL NETWORK GATEWAY SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway
resource "azurerm_local_network_gateway" "this" {
	for_each            = { for idx, s in var.localnet : idx => s }
	name                = each.value.local_gateway_name
	location            = each.value.location
	resource_group_name = each.value.resource_group_name
	gateway_address     = each.value.local_gateway_ip
	address_space       = each.value.local_gateway_address_space
	tags                = local.tags[each.key]
}
