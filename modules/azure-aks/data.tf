# Data section
data "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_public_ip" "aks_public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}
