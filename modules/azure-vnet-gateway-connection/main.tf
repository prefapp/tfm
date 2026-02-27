## VPN CONNECTION SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection
resource "azurerm_virtual_network_gateway_connection" "this" {
	for_each                   = { for idx, s in var.connection : idx => s }
	name                       = each.value.name
	location                   = each.value.location
	resource_group_name        = each.value.resource_group_name
	tags                       = local.tags
	type                       = each.value.type
	virtual_network_gateway_id = data.azurerm_virtual_network_gateway.this.id
	local_network_gateway_id   = azurerm_local_network_gateway.this[each.key].id
	shared_key                 = coalesce(
		try(each.value.shared_key, null),
		try(data.azurerm_key_vault_secret.s2s[each.key].value, null)
	)
	enable_bgp                 = each.value.enable_bgp

	dynamic "ipsec_policy" {
		for_each = try(each.value.ipsec_policy != null, false) ? [each.value.ipsec_policy] : []
		content {
			dh_group         = ipsec_policy.value.dh_group
			ike_encryption   = ipsec_policy.value.ike_encryption
			ike_integrity    = ipsec_policy.value.ike_integrity
			ipsec_encryption = ipsec_policy.value.ipsec_encryption
			ipsec_integrity  = ipsec_policy.value.ipsec_integrity
			pfs_group        = ipsec_policy.value.pfs_group
			sa_lifetime      = ipsec_policy.value.sa_lifetime
		}
	}
}
