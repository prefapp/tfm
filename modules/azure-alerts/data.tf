# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  count = var.common.tags_from_rg ? 1 : 0
  name = local.resource_group_name
}
