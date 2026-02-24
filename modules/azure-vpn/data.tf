## DATA SOURCES SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_resource_group" "this" {
  name = var.vpn.resource_group_name
}

data "azurerm_subnet" "this" {
  name                 = var.vpn.gateway_subnet_name
  virtual_network_name = var.vpn.vnet_name
  resource_group_name  = var.vpn.resource_group_name
}

data "azurerm_public_ip" "this" {
  name                = var.vpn.ip_name
  resource_group_name = var.vpn.resource_group_name
}
