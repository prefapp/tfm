## LOCALS SECTION

locals {
  # Handle tags based on whether to use resource group tags or module-defined tags for each local network gateway (key = idx)
  tags = { for idx, s in var.localnet :
    idx => (
      coalesce(s.tags_from_rg, false)
      ? merge(lookup(data.azurerm_resource_group.this, idx, null) != null ? data.azurerm_resource_group.this[idx].tags : {}, try(s.tags, {}))
      : try(s.tags, {})
    )
  }
}
