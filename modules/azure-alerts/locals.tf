locals {
  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.common.tags_from_rg ? merge(
    try(
      data.azurerm_resource_group.this[0].tags,
      {}
    ),
    var.common.tags
  ) : var.common.tags
}
