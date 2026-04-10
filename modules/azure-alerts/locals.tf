locals {
  # Effective resource group name: prefer common.resource_group_name when set,
  # otherwise fall back to the single action_group or the first action_groups resource group.
  resource_group_name = coalesce(
    var.common.resource_group_name,
    try(var.action_group.resource_group_name, null),
    try(values(var.action_groups)[0].resource_group_name, null)
  )

  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.common.tags_from_rg ? merge(
    try(
      data.azurerm_resource_group.this[0].tags,
      {}
    ),
    var.common.tags
  ) : var.common.tags

  configured_action_groups = merge(
    var.action_group != null ? { default = var.action_group } : {},
    var.action_groups
  )

  managed_action_groups = {
    for key, ag in local.configured_action_groups : key => ag
    if try(ag.create, true)
  }

  existing_action_groups = {
    for key, ag in local.configured_action_groups : key => ag
    if !try(ag.create, true)
  }

  action_group_ids_by_key = merge(
    { for key, ag in local.managed_action_groups : key => azurerm_monitor_action_group.this[key].id },
    { for key, ag in local.existing_action_groups : key => data.azurerm_monitor_action_group.this[key].id }
  )

  action_group_names_by_key = merge(
    { for key, ag in local.managed_action_groups : key => azurerm_monitor_action_group.this[key].name },
    { for key, ag in local.existing_action_groups : key => data.azurerm_monitor_action_group.this[key].name }
  )

  action_group_ids_by_ref = merge(
    {
      for key, ag in local.managed_action_groups :
      "${ag.resource_group_name}/${ag.name}" => azurerm_monitor_action_group.this[key].id
    },
    {
      for key, ag in local.existing_action_groups :
      "${ag.resource_group_name}/${ag.name}" => data.azurerm_monitor_action_group.this[key].id
    }
  )

  action_group_id   = length(local.action_group_ids_by_key) == 1 ? values(local.action_group_ids_by_key)[0] : null
  action_group_name = length(local.action_group_names_by_key) == 1 ? values(local.action_group_names_by_key)[0] : null

  quota_action_group_ids = var.quota_alert == null ? [] : (
    length(try(var.quota_alert.action_group_ids, [])) > 0
    ? var.quota_alert.action_group_ids
    : values(local.action_group_ids_by_key)
  )

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
    } if !entry.is_id && !contains(keys(local.action_group_ids_by_ref), "${entry.resource_group_name}/${entry.name}")
  }
}
