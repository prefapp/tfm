#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "aks_subnet" {
  count                = var.aks_subnet_id ? 0 : 1
  name                 = var.aks_subnet_name
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = var.aks_vnet_name_resource_group
}
