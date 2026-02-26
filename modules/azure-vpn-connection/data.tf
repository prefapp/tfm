## DATA SOURCES SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_resource_group" "this" {
  name = var.vpn.resource_group_name
}
