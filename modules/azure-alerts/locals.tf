locals {
  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.common.tags_from_rg && var.common.resource_group_name != null ? merge(data.azurerm_resource_group.this.tags, var.common.tags) : var.common.tags
}
