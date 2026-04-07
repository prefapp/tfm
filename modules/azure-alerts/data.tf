# https://registry.terraform.io/providers/hashicorp/azurerm/3.91.0/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  count = var.common.tags_from_rg ? 1 : 0
  name = var.common.resource_group_name
}
