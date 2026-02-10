## LOCALS SECTION

locals {
  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.this.tags, var.tags) : var.tags
}
