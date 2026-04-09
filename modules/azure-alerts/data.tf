# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  count = var.common.tags_from_rg ? 1 : 0
  name  = local.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group
data "azurerm_monitor_action_group" "budget" {
  for_each = toset(try(flatten([
    for n in var.budget.notification : n.contact_groups
  ]), []))

  name                = each.key
  resource_group_name = local.resource_group_name
}
