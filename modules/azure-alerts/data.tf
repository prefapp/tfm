# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  count = var.common.tags_from_rg ? 1 : 0
  name  = local.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

# Fetch the existing action group when create = false (brownfield / import mode).
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group
data "azurerm_monitor_action_group" "this" {
  count               = var.action_group.create ? 0 : 1
  name                = var.action_group.name
  resource_group_name = coalesce(var.action_group.resource_group_name, local.resource_group_name)
}

# Resolve contact_group names to IDs for budget notifications.
# Only entries that are NOT already full resource IDs (i.e. do not start with "/") are looked up.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group
data "azurerm_monitor_action_group" "budget" {
  for_each = toset(try(flatten([
    for n in var.budget.notification : [
      for g in n.contact_groups : g if !startswith(g, "/")
    ]
  ]), []))

  name                = each.key
  resource_group_name = local.resource_group_name
}
