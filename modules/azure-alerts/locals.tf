locals {
  action_group_resource_group_names = distinct([
    for _, ag in var.action_group : ag.resource_group_name
  ])

  # Effective resource group name: prefer common.resource_group_name when set,
  # otherwise fall back only when all configured action groups share the same RG.
  resource_group_name = coalesce(
    var.common.resource_group_name,
    length(local.action_group_resource_group_names) == 1 ? local.action_group_resource_group_names[0] : null
  )

  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.common.tags_from_rg ? merge(
    try(data.azurerm_resource_group.this[0].tags, {}),
    var.common.tags
  ) : var.common.tags

  managed_action_groups = var.action_group

  managed_action_group_ref_keys = {
    for _, ag in var.action_group : "${ag.resource_group_name}/${ag.name}" => true
  }

  action_group_ids_by_key = {
    for key, _ in local.managed_action_groups : key => azurerm_monitor_action_group.this[key].id
  }

  action_group_names_by_key = {
    for key, _ in local.managed_action_groups : key => azurerm_monitor_action_group.this[key].name
  }

  action_group_ids_by_ref = {
    for key, ag in local.managed_action_groups : "${ag.resource_group_name}/${ag.name}" => azurerm_monitor_action_group.this[key].id
  }

  action_group_id   = length(local.action_group_ids_by_key) == 1 ? values(local.action_group_ids_by_key)[0] : null
  action_group_name = length(local.action_group_names_by_key) == 1 ? values(local.action_group_names_by_key)[0] : null

  # Name/object based references that must be resolved by data source (excluding groups managed in this module)
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
    } if !entry.is_id && !contains(keys(local.managed_action_group_ref_keys), "${entry.resource_group_name}/${entry.name}")
  }

  quota_contact_group_lookups = var.quota_alert == null ? {} : {
    for entry in flatten([
      for group in(
        length(coalesce(try(var.quota_alert.action_groups, null), [])) > 0
        ? coalesce(try(var.quota_alert.action_groups, null), [])
        : [for _, ag in var.action_group : { name = ag.name, resource_group_name = ag.resource_group_name }]
        ) : {
        is_id               = can(tostring(group)) && startswith(tostring(group), "/")
        name                = can(tostring(group)) ? tostring(group) : group.name
        resource_group_name = can(tostring(group)) ? local.resource_group_name : try(group.resource_group_name, local.resource_group_name)
      }
      ]) : "${entry.resource_group_name}/${entry.name}" => {
      name                = entry.name
      resource_group_name = entry.resource_group_name
    } if !entry.is_id && !contains(keys(local.managed_action_group_ref_keys), "${entry.resource_group_name}/${entry.name}")
  }

  log_contact_group_lookups = {
    for entry in flatten([
      for alert in var.log_alert : (
        try(alert.action.action_group, null) != null
        ? [{
          is_id               = can(tostring(alert.action.action_group)) && startswith(tostring(alert.action.action_group), "/")
          name                = can(tostring(alert.action.action_group)) ? tostring(alert.action.action_group) : alert.action.action_group.name
          resource_group_name = can(tostring(alert.action.action_group)) ? local.resource_group_name : try(alert.action.action_group.resource_group_name, local.resource_group_name)
        }]
        : []
      )
      ]) : "${entry.resource_group_name}/${entry.name}" => {
      name                = entry.name
      resource_group_name = entry.resource_group_name
    } if !entry.is_id && !contains(keys(local.managed_action_group_ref_keys), "${entry.resource_group_name}/${entry.name}")
  }

  referenced_action_group_lookups = merge(
    local.budget_contact_group_lookups,
    local.quota_contact_group_lookups,
    local.log_contact_group_lookups
  )

  quota_action_group_ids = var.quota_alert == null ? [] : [
    for group in(
      length(try(var.quota_alert.action_groups, [])) > 0
      ? var.quota_alert.action_groups
      : [for _, ag in var.action_group : { name = ag.name, resource_group_name = ag.resource_group_name }]
      ) : (
      can(tostring(group)) && startswith(tostring(group), "/")
      ? tostring(group)
      : can(tostring(group))
      ? (
        local.resource_group_name == null
        ? null
        : try(
          local.action_group_ids_by_ref["${local.resource_group_name}/${tostring(group)}"],
          data.azurerm_monitor_action_group.referenced["${local.resource_group_name}/${tostring(group)}"].id
        )
      )
      : (
        try(group.resource_group_name, local.resource_group_name) == null
        ? null
        : try(
          local.action_group_ids_by_ref["${try(group.resource_group_name, local.resource_group_name)}/${group.name}"],
          data.azurerm_monitor_action_group.referenced["${try(group.resource_group_name, local.resource_group_name)}/${group.name}"].id
        )
      )
    )
  ]

  log_action_group_ids = {
    for alert in var.log_alert : alert.name => (
      try(alert.action.action_group_id, null) != null
      ? alert.action.action_group_id
      : (
        try(alert.action.action_group, null) != null
        ? (
          can(tostring(alert.action.action_group)) && startswith(tostring(alert.action.action_group), "/")
          ? tostring(alert.action.action_group)
          : (
            can(tostring(alert.action.action_group))
            ? (
              local.resource_group_name == null
              ? null
              : try(
                local.action_group_ids_by_ref[
                  "${local.resource_group_name}/${tostring(alert.action.action_group)}"
                ],
                data.azurerm_monitor_action_group.referenced[
                  "${local.resource_group_name}/${tostring(alert.action.action_group)}"
                ].id
              )
            )
            : (
              try(alert.action.action_group.resource_group_name, local.resource_group_name) == null
              ? null
              : try(
                local.action_group_ids_by_ref[
                  "${try(alert.action.action_group.resource_group_name, local.resource_group_name)}/${alert.action.action_group.name}"
                ],
                data.azurerm_monitor_action_group.referenced[
                  "${try(alert.action.action_group.resource_group_name, local.resource_group_name)}/${alert.action.action_group.name}"
                ].id
              )
            )
          )
        )
        : local.action_group_id
      )
    )
  }
}
