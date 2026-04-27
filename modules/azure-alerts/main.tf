
# Budget Alert at the subscription level to monitor the costs and send notifications when the specified threshold is reached
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription
resource "azurerm_consumption_budget_subscription" "this" {
  for_each        = local.budget_entries
  name            = each.value.name
  subscription_id = try(each.value.subscription_id, null) != null ? each.value.subscription_id : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  amount          = each.value.amount
  time_grain      = each.value.time_grain

  time_period {
    start_date = each.value.time_period.start_date
    end_date   = try(each.value.time_period.end_date, null)
  }

  dynamic "filter" {
    for_each = try(each.value.filter, null) != null ? [each.value.filter] : []
    content {
      dynamic "dimension" {
        for_each = coalesce(try(filter.value.dimension, null), [])
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
      dynamic "tag" {
        for_each = coalesce(try(filter.value.tag, null), [])
        content {
          name     = tag.value.name
          operator = tag.value.operator
          values   = tag.value.values
        }
      }
    }
  }

  dynamic "notification" {
    for_each = each.value.notification
    content {
      enabled        = notification.value.enabled
      operator       = notification.value.operator
      threshold      = notification.value.threshold
      threshold_type = try(notification.value.threshold_type, "Actual")
      contact_emails = notification.value.contact_emails
      contact_groups = compact([
        for g in coalesce(try(notification.value.contact_groups, null), []) : (
          can(tostring(g)) && startswith(tostring(g), "/")
          ? tostring(g)
          : can(tostring(g))
          ? (
            local.resource_group_name != null
            ? try(
              local.action_group_ids_by_ref["${local.resource_group_name}/${tostring(g)}"],
              data.azurerm_monitor_action_group.referenced["${local.resource_group_name}/${tostring(g)}"].id
            )
            : null
          )
          : (
            coalesce(try(g.resource_group_name, null), local.resource_group_name) != null
            ? try(
              local.action_group_ids_by_ref["${coalesce(try(g.resource_group_name, null), local.resource_group_name)}/${g.name}"],
              data.azurerm_monitor_action_group.referenced["${coalesce(try(g.resource_group_name, null), local.resource_group_name)}/${g.name}"].id
            )
            : null
          )
        )
      ])
      contact_roles = try(notification.value.contact_roles, [])
    }
  }

  lifecycle {
    precondition {
      condition = local.resource_group_name != null || !anytrue([
        for notification in each.value.notification :
        anytrue([
          for group in coalesce(try(notification.contact_groups, null), []) : (
            can(tostring(group)) ? !startswith(tostring(group), "/") :
            try(group.resource_group_name, null) == null
          )
        ])
      ])
      error_message = "When budget '${each.key}' uses notification[*].contact_groups by name or by object without resource_group_name, either common.resource_group_name must be set or a single action_group entry must be configured so its resource group can be inferred."
    }
  }
}

# Rule for Quota Alert to monitor the quota metrics at the subscription level and send notifications when the specified threshold is reached
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "quota" {
  for_each = local.resource_group_name != null ? local.quota_alert_entries : {}

  name                             = each.value.name
  resource_group_name              = local.resource_group_name
  location                         = each.value.location
  display_name                     = each.value.display_name
  description                      = try(each.value.description, null)
  enabled                          = each.value.enabled
  auto_mitigation_enabled          = try(each.value.auto_mitigation_enabled, null)
  evaluation_frequency             = each.value.evaluation_frequency
  scopes                           = each.value.scopes
  severity                         = each.value.severity
  skip_query_validation            = each.value.skip_query_validation
  target_resource_types            = each.value.target_resource_types
  window_duration                  = each.value.window_duration
  workspace_alerts_storage_enabled = each.value.workspace_alerts_storage_enabled

  criteria {
    metric_measure_column   = each.value.criteria.metric_measure_column
    operator                = each.value.criteria.operator
    query                   = each.value.criteria.query
    threshold               = each.value.criteria.threshold
    time_aggregation_method = each.value.criteria.time_aggregation_method

    dynamic "dimension" {
      for_each = each.value.criteria.dimension
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }

    failing_periods {
      minimum_failing_periods_to_trigger_alert = each.value.criteria.failing_periods.minimum_failing_periods_to_trigger_alert
      number_of_evaluation_periods             = each.value.criteria.failing_periods.number_of_evaluation_periods
    }
  }

  identity {
    type         = try(each.value.identity.type, "UserAssigned")
    identity_ids = length(azurerm_user_assigned_identity.quota_alert_reader) > 0 ? [azurerm_user_assigned_identity.quota_alert_reader[0].id] : coalesce(try(each.value.identity.identity_ids, null), [])
  }

  action {
    action_groups = local.quota_action_group_ids[each.key]
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = length(azurerm_user_assigned_identity.quota_alert_reader) > 0 || length(coalesce(try(each.value.identity.identity_ids, null), [])) > 0
      error_message = "When quota_alert '${each.key}' is set, either provide quota_alert['${each.key}'].identity.identity_ids or let the module create the Reader identity automatically (default)."
    }

    precondition {
      condition     = length(local.quota_action_group_ids[each.key]) > 0
      error_message = "When quota_alert '${each.key}' is set, configure at least one action_group entry or provide quota_alert['${each.key}'].action_groups explicitly."
    }
  }
}

# Activity Log Alerts to monitor the activity logs at the subscription level and send notifications when the specified conditions are met
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert
resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = {
    for alert in var.log_alert : alert.name => alert
    if coalesce(try(alert.resource_group_name, null), local.resource_group_name) != null
  }

  name                = each.value.name
  resource_group_name = coalesce(each.value.resource_group_name, local.resource_group_name)
  location            = each.value.location
  scopes              = each.value.scopes
  description         = try(each.value.description, null)
  enabled             = each.value.enabled

  criteria {
    category           = each.value.criteria.category
    levels             = length(coalesce(try(each.value.criteria.levels, null), [])) > 0 ? coalesce(try(each.value.criteria.levels, null), []) : null
    resource_groups    = length(coalesce(try(each.value.criteria.resource_groups, null), [])) > 0 ? coalesce(try(each.value.criteria.resource_groups, null), []) : null
    resource_ids       = length(coalesce(try(each.value.criteria.resource_ids, null), [])) > 0 ? coalesce(try(each.value.criteria.resource_ids, null), []) : null
    resource_providers = length(coalesce(try(each.value.criteria.resource_providers, null), [])) > 0 ? coalesce(try(each.value.criteria.resource_providers, null), []) : null
    resource_types     = length(coalesce(try(each.value.criteria.resource_types, null), [])) > 0 ? coalesce(try(each.value.criteria.resource_types, null), []) : null
    statuses           = length(coalesce(try(each.value.criteria.statuses, null), [])) > 0 ? coalesce(try(each.value.criteria.statuses, null), []) : null
    sub_statuses       = length(coalesce(try(each.value.criteria.sub_statuses, null), [])) > 0 ? coalesce(try(each.value.criteria.sub_statuses, null), []) : null

    dynamic "service_health" {
      for_each = try(each.value.criteria.service_health, null) != null ? [each.value.criteria.service_health] : []
      content {
        events    = length(coalesce(try(service_health.value.events, null), [])) > 0 ? coalesce(try(service_health.value.events, null), []) : null
        locations = length(coalesce(try(service_health.value.locations, null), [])) > 0 ? coalesce(try(service_health.value.locations, null), []) : null
        services  = length(coalesce(try(service_health.value.services, null), [])) > 0 ? coalesce(try(service_health.value.services, null), []) : null
      }
    }
  }

  action {
    action_group_id    = local.log_action_group_ids[each.key]
    webhook_properties = try(each.value.action.webhook_properties, {})
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = local.log_action_group_ids[each.key] != null
      error_message = "Each log_alert requires action.action_group (name/object/id), action.action_group_id, or exactly one configured action_group entry."
    }

    precondition {
      condition = local.resource_group_name != null || (
        try(each.value.action.action_group, null) == null ||
        (can(tostring(each.value.action.action_group)) && startswith(tostring(each.value.action.action_group), "/")) ||
        try(each.value.action.action_group.resource_group_name, null) != null
      )
      error_message = "log_alert '${each.key}' references an Action Group by name or by object without resource_group_name. Set common.resource_group_name (or configure a single action_group entry so its resource group can be inferred) to resolve the Action Group."
    }
  }
}

# Alert Processing Rule to suppress the alerts during the backup window
resource "azurerm_monitor_alert_processing_rule_action_group" "backup" {
  for_each = {
    for key, alert in local.backup_alert_entries : key => alert
    if coalesce(try(alert.resource_group_name, null), local.resource_group_name) != null
  }

  name                 = each.value.name
  resource_group_name  = coalesce(try(each.value.resource_group_name, null), local.resource_group_name)
  scopes               = each.value.scopes
  description          = try(each.value.description, null)
  add_action_group_ids = each.value.add_action_group_ids

  tags = local.tags
}
