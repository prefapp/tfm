locals {
  # If tags_from_rg is true, merge the tags from the resource group with the provided tags. Otherwise, use the provided tags as is.
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.resource_group[0].tags, var.tags) : var.tags
}
