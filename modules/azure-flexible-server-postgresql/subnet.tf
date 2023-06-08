data "azurerm_subnet" "subnet" {
  count                = lookup(local.data.subnet, "name", "NOT_DEFINED") == "NOT_DEFINED" ? 0 : 1
  name                 = local.data.subnet.name
  virtual_network_name = local.data.subnet.vnet.name
  resource_group_name  = local.data.subnet.vnet.resource_group
}