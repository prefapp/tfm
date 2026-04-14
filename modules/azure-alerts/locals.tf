locals {
  # Distinct resource group names used by configured action groups.
  action_group_resource_group_names = distinct([
    for _, ag in var.action_group : ag.resource_group_name
  ])

  # Effective resource group name: prefer common.resource_group_name; otherwise infer only when there is a single RG.
  resource_group_name = coalesce(
    var.common.resource_group_name,
    length(local.action_group_resource_group_names) == 1 ? local.action_group_resource_group_names[0] : null
  )

  # Final tags: merge RG tags (optional) with user-provided module tags.
  tags = var.common.tags_from_rg ? merge(
    try(data.azurerm_resource_group.this[0].tags, {}),
    var.common.tags
  ) : var.common.tags

  # Alias to simplify references to action_group input.
  managed_action_groups = var.action_group

  # Membership map of managed action groups by "resource_group/name".
  managed_action_group_ref_keys = {
    for _, ag in var.action_group : "${ag.resource_group_name}/${ag.name}" => true
  }

  # Map managed action group input keys to created action group IDs.
  action_group_ids_by_key = {
    for key, _ in local.managed_action_groups : key => azurerm_monitor_action_group.this[key].id
  }

  # Map managed action group input keys to created action group names.
  action_group_names_by_key = {
    for key, _ in local.managed_action_groups : key => azurerm_monitor_action_group.this[key].name
  }

  # Map "resource_group/name" references to created action group IDs.
  action_group_ids_by_ref = {
    for key, ag in local.managed_action_groups : "${ag.resource_group_name}/${ag.name}" => azurerm_monitor_action_group.this[key].id
  }

  # Single-action-group ID fallback used when exactly one managed action group exists.
  action_group_id = length(local.action_group_ids_by_key) == 1 ? values(local.action_group_ids_by_key)[0] : null

  # Single-action-group name fallback used when exactly one managed action group exists.
  action_group_name = length(local.action_group_names_by_key) == 1 ? values(local.action_group_names_by_key)[0] : null

  # Source groups referenced by budget notifications.
  budget_contact_group_sources = flatten([
    for _, budget in var.budget : [
      for notification in budget.notification : coalesce(try(notification.contact_groups, null), [])
    ]
  ])

  # Source groups referenced by quota alert, with fallback to managed action groups.
  quota_contact_group_sources = flatten([
    for _, quota in var.quota_alert : (
      length(coalesce(try(quota.action_groups, null), [])) > 0
      ? coalesce(try(quota.action_groups, null), [])
      : [for _, ag in var.action_group : { name = ag.name, resource_group_name = ag.resource_group_name }]
    )
  ])

  # Source groups referenced by log alerts.
  log_contact_group_sources = flatten([
    for alert in var.log_alert : (
      try(alert.action.action_group, null) != null
      ? [alert.action.action_group]
      : []
    )
  ])

  # Normalized external references (ID vs name/object) with resolved resource group fallback.
  external_contact_group_entries = [
    for group in concat(
      local.budget_contact_group_sources,
      local.quota_contact_group_sources,
      local.log_contact_group_sources
      ) : {
      is_id               = can(tostring(group)) && startswith(tostring(group), "/")
      name                = can(tostring(group)) ? tostring(group) : group.name
      resource_group_name = can(tostring(group)) ? local.resource_group_name : coalesce(try(group.resource_group_name, null), local.resource_group_name)
    }
  ]

  # External action groups to lookup by data source, excluding IDs and module-managed groups.
  referenced_action_group_lookups = {
    for entry in local.external_contact_group_entries : "${entry.resource_group_name}/${entry.name}" => {
      name                = entry.name
      resource_group_name = entry.resource_group_name
    } if !entry.is_id && entry.resource_group_name != null && !contains(keys(local.managed_action_group_ref_keys), "${entry.resource_group_name}/${entry.name}")
  }

  # Resolved quota action group IDs per quota alert from explicit IDs, managed groups, or external lookups.
  quota_action_group_ids = {
    for quota_key, quota in var.quota_alert : quota_key => compact([
      for group in(
        length(coalesce(try(quota.action_groups, null), [])) > 0
        ? coalesce(try(quota.action_groups, null), [])
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
          coalesce(try(group.resource_group_name, null), local.resource_group_name) == null
          ? null
          : try(
            local.action_group_ids_by_ref["${coalesce(try(group.resource_group_name, null), local.resource_group_name)}/${group.name}"],
            data.azurerm_monitor_action_group.referenced["${coalesce(try(group.resource_group_name, null), local.resource_group_name)}/${group.name}"].id
          )
        )
      )
    ])
  }

  # Resolved action group ID per log alert from action_group_id, action_group reference, or singleton fallback.
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
              coalesce(try(alert.action.action_group.resource_group_name, null), local.resource_group_name) == null
              ? null
              : try(
                local.action_group_ids_by_ref[
                  "${coalesce(try(alert.action.action_group.resource_group_name, null), local.resource_group_name)}/${alert.action.action_group.name}"
                ],
                data.azurerm_monitor_action_group.referenced[
                  "${coalesce(try(alert.action.action_group.resource_group_name, null), local.resource_group_name)}/${alert.action.action_group.name}"
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
