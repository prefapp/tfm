## VPN CONNECTION SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection
resource "azurerm_virtual_network_gateway_connection" "this" {
  private_link_fast_path_enabled = try(each.value.private_link_fast_path_enabled, null)
  dynamic "traffic_selector_policy" {
    for_each = coalesce(each.value.traffic_selector_policy, [])
    content {
      local_address_cidrs  = traffic_selector_policy.value.local_address_cidrs
      remote_address_cidrs = traffic_selector_policy.value.remote_address_cidrs
    }
  }
  for_each                       = { for s in var.connection : s.name => s }
  name                           = each.value.name
  location                       = each.value.location
  resource_group_name            = each.value.resource_group_name
  egress_nat_rule_ids            = try(each.value.egress_nat_rule_ids, null)
  ingress_nat_rule_ids           = try(each.value.ingress_nat_rule_ids, null)
  local_azure_ip_address_enabled = try(each.value.local_azure_ip_address_enabled, null)
  tags                           = local.tags[each.key]
  type                           = each.value.type
  virtual_network_gateway_id = (
    try(each.value.virtual_network_gateway_id, null) != null ? each.value.virtual_network_gateway_id : data.azurerm_virtual_network_gateway.this[each.key].id
  )
  local_network_gateway_id = (
    each.value.type == "IPsec" ?
    (
      try(each.value.local_network_gateway_id, null) != null ? each.value.local_network_gateway_id : data.azurerm_local_network_gateway.this[each.key].id
    ) : null
  )
  shared_key = (
    try(each.value.shared_key, null) != null ? each.value.shared_key : (
      try(data.azurerm_key_vault_secret.this[each.key].value, null) != null ? data.azurerm_key_vault_secret.this[each.key].value : null
    )
  )
  bgp_enabled = try(each.value.bgp_enabled, null)
  dynamic "custom_bgp_addresses" {
    for_each = try(each.value.custom_bgp_addresses != null, false) ? [each.value.custom_bgp_addresses] : []
    content {
      primary   = custom_bgp_addresses.value.primary
      secondary = custom_bgp_addresses.value.secondary
    }
  }
  connection_protocol                = try(each.value.connection_protocol, null)
  routing_weight                     = try(each.value.routing_weight, null)
  authorization_key                  = try(each.value.authorization_key, null)
  express_route_circuit_id           = try(each.value.express_route_circuit_id, null)
  peer_virtual_network_gateway_id    = try(each.value.peer_virtual_network_gateway_id, null)
  use_policy_based_traffic_selectors = try(each.value.use_policy_based_traffic_selectors, null)
  express_route_gateway_bypass       = try(each.value.express_route_gateway_bypass, null)
  dpd_timeout_seconds                = try(each.value.dpd_timeout_seconds, null)
  connection_mode                    = try(each.value.connection_mode, null)
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
      sa_datasize      = ipsec_policy.value.sa_datasize
    }
  }
  # NOTE: Changes to `shared_key` are intentionally ignored to avoid
  #       unintended reconfiguration of existing VPN connections.
  #       This means Terraform will NOT apply shared key rotations or
  #       updates even if the input value or the backing Key Vault
  #       secret changes. Operators who require Terraform-managed
  #       key rotation should remove this `ignore_changes` setting
  #       (e.g. in a forked module) and plan for the impact of
  #       updating VPN connection shared keys.
  lifecycle {
    ignore_changes = [shared_key]
  }
}
