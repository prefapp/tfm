## DATA SOURCES SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_resource_group" "this" {
	for_each = { for idx, s in var.localnet : idx => s }
	name     = each.value.resource_group_name
}
