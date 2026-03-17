## DATA SOURCES SECTION


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  name = var.vpn.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "this" {
  count                = var.vpn.gateway_subnet_id == null ? 1 : 0
  name                 = var.vpn.gateway_subnet_name
  virtual_network_name = var.vpn.vnet_name
  resource_group_name  = var.vpn.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip
data "azurerm_public_ip" "this" {
  for_each            = { for ipconf in var.vpn.ip_configurations : ipconf.name => ipconf if try(ipconf.public_ip_name, null) != null && try(ipconf.public_ip_id, null) == null }
  name                = each.value.public_ip_name
  resource_group_name = var.vpn.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network_gateway
data "azurerm_virtual_network_gateway" "this" {
  count               = var.vpn.default_local_network_gateway_id == null ? 1 : 0
  name                = var.vpn.default_local_network_gateway_name
  resource_group_name = var.vpn.resource_group_name
}
