# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "resorce_group" {
  provider = var.provider_dst != null ? var.provider_dst : azurerm
  name     = var.name
  location = var.location
  tags     = var.tags != null ? var.tags : {}
}
