# Data section
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity
data "azurerm_user_assigned_identity" "that" {
  name                = var.user_assigned_identity #"appgw-management-certs"
  resource_group_name = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "that" {
  name                 =  var.subnet.name
  virtual_network_name =  var.subnet.virtual_network_name
  resource_group_name  =  var.resource_group_name
}
