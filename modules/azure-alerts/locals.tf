locals {
  # Effective resource group name: prefer common.resource_group_name when set,
  # fall back to the required action_group.resource_group_name.
  resource_group_name = coalesce(var.common.resource_group_name, var.action_group.resource_group_name)

  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.common.tags_from_rg ? merge(
    try(
      data.azurerm_resource_group.this[0].tags,
      {}
    ),
    var.common.tags
  ) : var.common.tags
}
