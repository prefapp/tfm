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
  count               = var.vpn.public_ip_id == null ? 1 : 0
  name                = var.vpn.public_ip_name
  resource_group_name = var.vpn.resource_group_name
}


