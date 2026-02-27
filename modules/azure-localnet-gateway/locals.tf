## LOCALS SECTION

locals {
  # tags por cada localnet (key = idx)
  tags = { for idx, s in var.localnet :
    idx => (
      var.tags_from_rg
      ? merge(lookup(data.azurerm_resource_group.this, idx, null) != null ? data.azurerm_resource_group.this[idx].tags : {}, var.tags)
      : var.tags
    )
  }
}
