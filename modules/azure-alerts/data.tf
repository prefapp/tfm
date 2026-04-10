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
  for_each = local.existing_action_groups

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

# Resolve contact_group names to IDs for budget notifications.
# Only entries that are NOT already full resource IDs are looked up.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group
data "azurerm_monitor_action_group" "budget" {
  for_each = local.budget_contact_group_lookups

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
