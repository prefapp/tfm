# Client configuration
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

# Data source to fetch the resource group (used for tag inheritance when common.tags_from_rg is enabled)
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "this" {
  count = var.common.tags_from_rg && local.resource_group_name != null ? 1 : 0
  name  = local.resource_group_name
}

# Resolve referenced action group names to IDs for budget/quota/log alerts
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_action_group
data "azurerm_monitor_action_group" "referenced" {
  for_each            = local.referenced_action_group_lookups
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
