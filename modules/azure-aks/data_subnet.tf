# Data source: azurerm_subnet
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "aks_subnet" {
  name                 = local.input.aks.network.subnet.subnet_name
  virtual_network_name = local.input.aks.network.subnet.vnet_name
  resource_group_name  = local.input.aks.network.subnet.vnet_name_resource_group
}
