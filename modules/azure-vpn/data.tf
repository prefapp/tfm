## DATA SOURCES SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_subnet" "this" {
  name                 = var.vpn.subnet.subnet_gw_name
  virtual_network_name = var.vpn.subnet.vnet_name
  resource_group_name  = var.vpn.subnet.resource_group_name
}

data "azurerm_public_ip" "this" {
  name                = var.vpn.ip.name
  resource_group_name = var.vpn.ip.resource_group_name
}
