## LOCALS SECTION

locals {
  # Handle tags based on whether to use resource group tags or module-defined tags for each connection (key = idx)
  tags = { for idx, s in var.connection :
    idx => (
      coalesce(s.tags_from_rg, false)
      ? merge(try(data.azurerm_resource_group.this[idx].tags, {}), try(s.tags, {}))
      : try(s.tags, {})
    )
  }
}
