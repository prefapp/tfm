# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "central-predev" {
  for_each                     = { for idx, peering in var.peerings : idx => peering }
  name                         = each.value.peering_name
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  allow_virtual_network_access = each.value.allow_virtual_network_access
  use_remote_gateways          = each.value.use_remote_gateways
  resource_group_name          = var.resource_group_name
  virtual_network_name         = each.value.vnet_name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
}
