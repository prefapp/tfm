# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags != null ? var.tags : {}
}
