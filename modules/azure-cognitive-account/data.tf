data "azurerm_resource_group" "this" {
  count = var.tags_from_rg ? 1 : 0

  name = var.resource_group_name
}
