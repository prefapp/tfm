## LOCALS SECTION

locals {
  # Handle tags based on whether to use resource group tags or module-defined tags for each connection (key = s.name)
  tags = { for s in var.connection :
    s.name => (
      coalesce(s.tags_from_rg, false)
      ? merge(
        coalesce(try(data.azurerm_resource_group.this[s.name].tags, null), {}),
        coalesce(s.tags, {})
      )
      : coalesce(s.tags, {})
    )
  }
}
