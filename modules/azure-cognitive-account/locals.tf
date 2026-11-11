locals {
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.this[0].tags, var.tags) : var.tags
}
