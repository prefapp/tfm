#Locals section
locals {
    tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group.tags, var.tags) : var.tags
}

#Data Section
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}
