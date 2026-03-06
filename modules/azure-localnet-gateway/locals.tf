## LOCALS SECTION

locals {
  # tags por cada localnet (key = idx)
  tags = { for idx, s in var.localnet :
    idx => (
      coalesce(s.tags_from_rg, false)
      ? merge(lookup(data.azurerm_resource_group.this, idx, null) != null ? data.azurerm_resource_group.this[idx].tags : {}, try(s.tags, {}))
      : try(s.tags, {})
    )
  }
}
