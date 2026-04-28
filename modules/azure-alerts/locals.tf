locals {
  # Normalized action group entries: accepts a list (preferred) or a legacy map.
  action_group_entries = (
    var.action_group == null ? [] : (
      can(tolist(var.action_group))
      ? [for ag in tolist(var.action_group) : ag]
      : [for _, ag in tomap(var.action_group) : ag]
    )
  )

  # Normalized budget entries: accepts a list (preferred) or a legacy map.
  budget_entries = (
    var.budget == null ? {} : (
      can(tolist(var.budget))
      ? { for budget in tolist(var.budget) : budget.name => budget }
      : { for _, budget in tomap(var.budget) : budget.name => budget }
    )
  )

  # Normalized quota alert entries: accepts a list (preferred) or a legacy map.
  quota_alert_entries = (
    var.quota_alert == null ? {} : (
      can(tolist(var.quota_alert))
      ? { for quota in tolist(var.quota_alert) : quota.name => quota }
      : { for _, quota in tomap(var.quota_alert) : quota.name => quota }
    )
  )

  # True when the module should create its own managed identity: at least one quota alert
  # is configured and at least one does not supply its own identity_ids.
  needs_module_identity = length(local.quota_alert_entries) > 0 && anytrue([
    for _, quota in local.quota_alert_entries : length(coalesce(try(quota.identity.identity_ids, null), [])) == 0
  ])

  # Normalized backup alert entries: accepts a list (preferred) or a legacy map.
  backup_alert_entries = (
    var.backup_alert == null ? {} : (
      can(tolist(var.backup_alert))
      ? { for alert in tolist(var.backup_alert) : alert.name => alert }
      : { for _, alert in tomap(var.backup_alert) : alert.name => alert }
    )
  )

  # Distinct resource group names used by configured action groups.
  action_group_resource_group_names = distinct([
    for _, ag in local.managed_action_groups : ag.resource_group_name
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
  managed_action_groups = {
    for ag in local.action_group_entries : ag.name => ag
  }

  # Membership map of managed action groups by "resource_group/name".
  # Validated: no two entries may share the same (resource_group_name, name) pair.
  managed_action_group_ref_keys = {
    for _, ag in local.managed_action_groups : "${ag.resource_group_name}/${ag.name}" => true
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
    for _, budget in local.budget_entries : [
      for notification in budget.notification : coalesce(try(notification.contact_groups, null), [])
    ]
  ])

  # Source groups referenced by quota alert, with fallback to managed action groups.
  # Normalize all entries to objects so conditional branches keep a consistent type.
  # Guard string conversion so unexpected object/list/map values in quota.action_groups
  # do not fail local evaluation with an Invalid function argument error.
  quota_contact_group_sources = flatten([
    for _, quota in local.quota_alert_entries : (
      length(coalesce(try(quota.action_groups, null), [])) > 0
      ? [for _, ag_ref in coalesce(try(quota.action_groups, null), []) : {
        id                  = can(regex("^/subscriptions/", try(tostring(ag_ref), ""))) ? try(tostring(ag_ref), null) : null
        name                = can(regex("^/subscriptions/", try(tostring(ag_ref), ""))) ? null : try(tostring(ag_ref), null)
        resource_group_name = null
      }]
      : [for _, ag in local.managed_action_groups : { id = null, name = ag.name, resource_group_name = ag.resource_group_name }]
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

  # Normalized source groups referenced by backup alerts.
  # Preferred input is backup_alert[*].action_group, but action_groups/add_action_group_ids
  # are accepted for backwards compatibility.
  backup_action_group_refs = {
    for key, alert in local.backup_alert_entries : key => (
      try(alert.action_group, null) != null
      ? try(
        [for _, g in tolist(alert.action_group) : g],
        [for _, g in tomap(alert.action_group) : g],
        [alert.action_group]
      )
      : try(alert.action_groups, null) != null
      ? try(
        [for _, g in tolist(alert.action_groups) : g],
        [for _, g in tomap(alert.action_groups) : g],
        [alert.action_groups]
      )
      : try(alert.add_action_group_ids, null) != null
      ? try(
        [for _, g in tolist(alert.add_action_group_ids) : g],
        [for _, g in tomap(alert.add_action_group_ids) : g],
        [alert.add_action_group_ids]
      )
      : []
    )
  }

  # Source groups referenced by backup alerts.
  backup_contact_group_sources = flatten(values(local.backup_action_group_refs))

  # Subscription IDs inferred from backup alert scopes when they are declared at subscription level.
  backup_action_group_scope_subscription_ids = {
    for alert_key, alert in local.backup_alert_entries : alert_key => distinct(compact([
      for scope in coalesce(try(alert.scopes, null), []) : (
        can(regex("^/subscriptions/[^/]+$", tostring(scope)))
        ? split("/", tostring(scope))[2]
        : null
      )
    ]))
  }

  # For backup alerts, build a cross-subscription Action Group ID directly when the alert scopes
  # identify a single subscription and the reference is given by name/object instead of full ID.
  backup_action_group_inferred_ids = {
    for alert_key, alert in local.backup_alert_entries : alert_key => {
      for group in [for _, ag_ref in local.backup_action_group_refs[alert_key] : (
        can(regex("^/subscriptions/", try(tostring(ag_ref), "")))
        ? { id = try(tostring(ag_ref), null), name = null, resource_group_name = null }
        : can(tostring(ag_ref))
        ? { id = null, name = try(tostring(ag_ref), null), resource_group_name = null }
        : { id = try(ag_ref.id, null), name = try(ag_ref.name, null), resource_group_name = try(ag_ref.resource_group_name, null) }
        )] : "${coalesce(try(group.resource_group_name, null), local.resource_group_name)}/${group.name}" => format(
        "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Insights/actionGroups/%s",
        local.backup_action_group_scope_subscription_ids[alert_key][0],
        coalesce(try(group.resource_group_name, null), local.resource_group_name),
        group.name
      ) if try(group.id, null) == null && coalesce(try(group.resource_group_name, null), local.resource_group_name) != null && try(group.name, null) != null && trimspace(group.name) != "" && length(local.backup_action_group_scope_subscription_ids[alert_key]) == 1
    }
  }

  backup_action_group_inferred_ref_keys = distinct(flatten([
    for _, refs in local.backup_action_group_inferred_ids : keys(refs)
  ]))

  # Normalized external references (ID vs name/object) with resolved resource group fallback.
  external_contact_group_entries = [
    for group in concat(
      local.budget_contact_group_sources,
      local.quota_contact_group_sources,
      local.log_contact_group_sources,
      local.backup_contact_group_sources
      ) : {
      is_id               = try(group.id, null) != null || (can(tostring(group)) && startswith(tostring(group), "/"))
      name                = try(group.id, null) != null ? group.id : (can(tostring(group)) ? tostring(group) : try(group.name, null))
      resource_group_name = try(group.id, null) != null ? null : (can(tostring(group)) ? local.resource_group_name : coalesce(try(group.resource_group_name, null), local.resource_group_name))
    }
  ]

  # External action groups to lookup by data source, excluding IDs and module-managed groups.
  referenced_action_group_lookups = {
    for entry in local.external_contact_group_entries : "${entry.resource_group_name}/${entry.name}" => {
      name                = entry.name
      resource_group_name = entry.resource_group_name
    } if !entry.is_id && entry.resource_group_name != null && entry.name != null && trimspace(entry.name) != "" && !contains(keys(local.managed_action_group_ref_keys), "${entry.resource_group_name}/${entry.name}") && !contains(local.backup_action_group_inferred_ref_keys, "${entry.resource_group_name}/${entry.name}")
  }

  # Resolved quota action group IDs per quota alert from explicit IDs, managed groups, or external lookups.
  quota_action_group_ids = {
    for quota_key, quota in local.quota_alert_entries : quota_key => compact([
      for group in(
        length(coalesce(try(quota.action_groups, null), [])) > 0
        ? [for _, ag_ref in coalesce(try(quota.action_groups, null), []) : (
          can(regex("^/subscriptions/", try(tostring(ag_ref), "")))
          ? { id = try(tostring(ag_ref), null), name = null, resource_group_name = null }
          : { id = null, name = try(tostring(ag_ref), null), resource_group_name = null }
        ) if try(tostring(ag_ref), null) != null]
        : [for _, ag in local.managed_action_groups : { id = null, name = ag.name, resource_group_name = ag.resource_group_name }]
        ) : (
        try(group.id, null) != null
        ? group.id
        : (
          coalesce(try(group.resource_group_name, null), local.resource_group_name) == null || try(group.name, null) == null || trimspace(group.name) == ""
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
              coalesce(try(alert.action.action_group.resource_group_name, null), local.resource_group_name) == null || try(alert.action.action_group.name, null) == null
              ? null
              : try(
                local.action_group_ids_by_ref[
                  "${coalesce(try(alert.action.action_group.resource_group_name, null), local.resource_group_name)}/${try(alert.action.action_group.name, null)}"
                ],
                data.azurerm_monitor_action_group.referenced[
                  "${coalesce(try(alert.action.action_group.resource_group_name, null), local.resource_group_name)}/${try(alert.action.action_group.name, null)}"
                ].id
              )
            )
          )
        )
        : local.action_group_id
      )
    )
  }

  # Resolved action group IDs per backup alert from explicit IDs, managed groups, or external lookups.
  backup_action_group_ids = {
    for alert_key, alert in local.backup_alert_entries : alert_key => compact([
      for group in [for _, ag_ref in local.backup_action_group_refs[alert_key] : (
        can(regex("^/subscriptions/", try(tostring(ag_ref), "")))
        ? { id = try(tostring(ag_ref), null), name = null, resource_group_name = null }
        : can(tostring(ag_ref))
        ? { id = null, name = try(tostring(ag_ref), null), resource_group_name = null }
        : { id = try(ag_ref.id, null), name = try(ag_ref.name, null), resource_group_name = try(ag_ref.resource_group_name, null) }
        )] : (
        try(group.id, null) != null
        ? group.id
        : (
          coalesce(try(group.resource_group_name, null), local.resource_group_name) == null || try(group.name, null) == null || trimspace(group.name) == ""
          ? null
          : try(
            local.action_group_ids_by_ref["${coalesce(try(group.resource_group_name, null), local.resource_group_name)}/${group.name}"],
            local.backup_action_group_inferred_ids[alert_key]["${coalesce(try(group.resource_group_name, null), local.resource_group_name)}/${group.name}"],
            data.azurerm_monitor_action_group.referenced["${coalesce(try(group.resource_group_name, null), local.resource_group_name)}/${group.name}"].id
          )
        )
      )
    ])
  }
}
