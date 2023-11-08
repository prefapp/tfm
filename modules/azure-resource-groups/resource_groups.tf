# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "resorce_group" {
  for_each = var.resource_groups
    name     = each.key
    location = each.value["location"]
    tags = lookup(each.value, "tags", null)
}
