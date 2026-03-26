## DATA SOURCES SECTION

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  for_each = { for idx, s in var.localnet : idx => s if try(s.tags_from_rg, false) }
  name     = each.value.resource_group_name
}
