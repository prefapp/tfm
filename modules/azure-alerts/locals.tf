locals {
  # Effective resource group name: prefer common.resource_group_name when set,
  # fall back to the required action_group.resource_group_name.
  resource_group_name = coalesce(var.common.resource_group_name, var.action_group.resource_group_name)

  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.common.tags_from_rg ? merge(
    try(
      data.azurerm_resource_group.this[0].tags,
      {}
    ),
    var.common.tags
  ) : var.common.tags

  # Resolved Action Group ID and name.
  # When create = true  → use the managed resource.
  # When create = false → use the data source (brownfield / import mode).
  action_group_id   = var.action_group.create ? azurerm_monitor_action_group.this[0].id : data.azurerm_monitor_action_group.this[0].id
  action_group_name = var.action_group.create ? azurerm_monitor_action_group.this[0].name : data.azurerm_monitor_action_group.this[0].name

  # Normalize budget notification contact groups so each entry can be:
  # - a full Action Group resource ID string,
  # - a name string resolved in local.resource_group_name,
  # - an object with `name` and optional `resource_group_name`.
  budget_contact_group_lookups = var.budget == null ? {} : {
    for entry in flatten([
      for notification in var.budget.notification : [
        for group in try(notification.contact_groups, []) : {
          is_id               = can(tostring(group)) && startswith(tostring(group), "/")
          name                = can(tostring(group)) ? tostring(group) : group.name
          resource_group_name = can(tostring(group)) ? local.resource_group_name : try(group.resource_group_name, local.resource_group_name)
        }
      ]
      ]) : "${entry.resource_group_name}/${entry.name}" => {
      name                = entry.name
      resource_group_name = entry.resource_group_name
    } if !entry.is_id
  }

  # Sort all receiver types by their `name` attribute for stable ordering across
  # plan/apply cycles. This prevents positional drift when Azure returns receivers
  # in a different order than Terraform's map-key alphabetical sort.
  email_receivers_sorted = {
    for r in sort([for v in var.action_group.email_receivers : v.name]) : r =>
    [for v in var.action_group.email_receivers : v if v.name == r][0]
  }
  arm_role_receivers_sorted = {
    for r in sort([for v in var.action_group.arm_role_receivers : v.name]) : r =>
    [for v in var.action_group.arm_role_receivers : v if v.name == r][0]
  }
  automation_runbook_receivers_sorted = {
    for r in sort([for v in var.action_group.automation_runbook_receivers : v.name]) : r =>
    [for v in var.action_group.automation_runbook_receivers : v if v.name == r][0]
  }
  azure_app_push_receivers_sorted = {
    for r in sort([for v in var.action_group.azure_app_push_receivers : v.name]) : r =>
    [for v in var.action_group.azure_app_push_receivers : v if v.name == r][0]
  }
  azure_function_receivers_sorted = {
    for r in sort([for v in var.action_group.azure_function_receivers : v.name]) : r =>
    [for v in var.action_group.azure_function_receivers : v if v.name == r][0]
  }
  event_hub_receivers_sorted = {
    for r in sort([for v in var.action_group.event_hub_receivers : v.name]) : r =>
    [for v in var.action_group.event_hub_receivers : v if v.name == r][0]
  }
  itsm_receivers_sorted = {
    for r in sort([for v in var.action_group.itsm_receivers : v.name]) : r =>
    [for v in var.action_group.itsm_receivers : v if v.name == r][0]
  }
  logic_app_receivers_sorted = {
    for r in sort([for v in var.action_group.logic_app_receivers : v.name]) : r =>
    [for v in var.action_group.logic_app_receivers : v if v.name == r][0]
  }
  sms_receivers_sorted = {
    for r in sort([for v in var.action_group.sms_receivers : v.name]) : r =>
    [for v in var.action_group.sms_receivers : v if v.name == r][0]
  }
  voice_receivers_sorted = {
    for r in sort([for v in var.action_group.voice_receivers : v.name]) : r =>
    [for v in var.action_group.voice_receivers : v if v.name == r][0]
  }
  webhook_receivers_sorted = {
    for r in sort([for v in var.action_group.webhook_receivers : v.name]) : r =>
    [for v in var.action_group.webhook_receivers : v if v.name == r][0]
  }
}
