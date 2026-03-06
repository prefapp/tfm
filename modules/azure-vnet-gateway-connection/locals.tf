## LOCALS SECTION

locals {
  # tags por cada connection (key = idx), siempre map(string)
  tags = { for idx, s in var.connection :
    idx => (
      coalesce(s.tags_from_rg, false)
      ? merge(try(data.azurerm_resource_group.this[idx].tags, {}), try(s.tags, {}))
      : try(s.tags, {})
    )
  }
}
