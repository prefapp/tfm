# Managed Identity for Quota Alert to read the quota metrics from the subscription
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "quota_alert_reader" {
  count               = var.quota_alert != null && var.identity != null ? 1 : 0
  name                = var.identity.name
  resource_group_name = local.resource_group_name
  location            = var.common.location
}

# Role Assignment for the Managed Identity to have Reader access on the subscription to read the quota metrics
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "quota_reader" {
  count                = var.quota_alert != null && var.identity != null ? 1 : 0
  scope                = var.identity.scope
  role_definition_name = var.identity.role_definition_name
  principal_id         = azurerm_user_assigned_identity.quota_alert_reader[0].principal_id
}

# Action Group for the alerts to send notifications to the specified email receivers
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group
resource "azurerm_monitor_action_group" "this" {
  for_each            = local.managed_action_groups
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = var.common.location
  short_name          = each.value.short_name

  dynamic "arm_role_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.arm_role_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.arm_role_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                    = arm_role_receiver.key
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = try(arm_role_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "automation_runbook_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.automation_runbook_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.automation_runbook_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                    = automation_runbook_receiver.key
      automation_account_id   = automation_runbook_receiver.value.automation_account_id
      runbook_name            = automation_runbook_receiver.value.runbook_name
      webhook_resource_id     = automation_runbook_receiver.value.webhook_resource_id
      service_uri             = automation_runbook_receiver.value.service_uri
      is_global_runbook       = automation_runbook_receiver.value.is_global_runbook
      use_common_alert_schema = try(automation_runbook_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "azure_app_push_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.azure_app_push_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.azure_app_push_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name          = azure_app_push_receiver.key
      email_address = azure_app_push_receiver.value.email_address
    }
  }

  dynamic "azure_function_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.azure_function_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.azure_function_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                     = azure_function_receiver.key
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
      use_common_alert_schema  = try(azure_function_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "email_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.email_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.email_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = try(email_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "event_hub_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.event_hub_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.event_hub_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                    = event_hub_receiver.key
      event_hub_name          = event_hub_receiver.value.event_hub_name
      event_hub_namespace     = event_hub_receiver.value.event_hub_namespace
      use_common_alert_schema = try(event_hub_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "itsm_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.itsm_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.itsm_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                 = itsm_receiver.key
      workspace_id         = itsm_receiver.value.workspace_id
      connection_id        = itsm_receiver.value.connection_id
      region               = itsm_receiver.value.region
      ticket_configuration = itsm_receiver.value.ticket_configuration
    }
  }

  dynamic "logic_app_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.logic_app_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.logic_app_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                    = logic_app_receiver.key
      resource_id             = logic_app_receiver.value.resource_id
      callback_url            = logic_app_receiver.value.callback_url
      use_common_alert_schema = try(logic_app_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "sms_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.sms_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.sms_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name         = sms_receiver.key
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "voice_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.voice_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.voice_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name         = voice_receiver.key
      country_code = voice_receiver.value.country_code
      phone_number = voice_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = {
      for name in sort([for receiver in values(each.value.webhook_receivers) : receiver.name]) : name =>
      [for receiver in values(each.value.webhook_receivers) : receiver if receiver.name == name][0]
    }
    content {
      name                    = webhook_receiver.key
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = try(webhook_receiver.value.use_common_alert_schema, true)

      dynamic "aad_auth" {
        for_each = webhook_receiver.value.aad_auth != null ? [webhook_receiver.value.aad_auth] : []
        content {
          object_id      = aad_auth.value.object_id
          identifier_uri = aad_auth.value.identifier_uri
          tenant_id      = aad_auth.value.tenant_id
        }
      }
    }
  }

  tags = local.tags
}

# Budget Alert at the subscription level to monitor the costs and send notifications when the specified threshold is reached
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription
resource "azurerm_consumption_budget_subscription" "this" {
  count           = var.budget != null ? 1 : 0
  name            = var.budget.name
  subscription_id = var.budget.subscription_id != null ? var.budget.subscription_id : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  amount          = var.budget.amount
  time_grain      = var.budget.time_grain

  time_period {
    start_date = var.budget.time_period.start_date
    end_date   = try(var.budget.time_period.end_date, null)
  }

  dynamic "filter" {
    for_each = var.budget.filter != null ? [var.budget.filter] : []
    content {
      dynamic "dimension" {
        for_each = filter.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
      dynamic "tag" {
        for_each = filter.value.tag
        content {
          name     = tag.value.name
          operator = tag.value.operator
          values   = tag.value.values
        }
      }
    }
  }

  dynamic "notification" {
    for_each = var.budget.notification
    content {
      enabled        = notification.value.enabled
      operator       = notification.value.operator
      threshold      = notification.value.threshold
      threshold_type = try(notification.value.threshold_type, "Actual")
      contact_emails = notification.value.contact_emails
      contact_groups = [
        for g in try(notification.value.contact_groups, []) : (
          can(tostring(g)) && startswith(tostring(g), "/")
          ? tostring(g)
          : try(
            local.action_group_ids_by_ref[
              can(tostring(g))
              ? "${local.resource_group_name}/${tostring(g)}"
              : "${try(g.resource_group_name, local.resource_group_name)}/${g.name}"
            ],
            data.azurerm_monitor_action_group.referenced[
              can(tostring(g))
              ? "${local.resource_group_name}/${tostring(g)}"
              : "${try(g.resource_group_name, local.resource_group_name)}/${g.name}"
            ].id
          )
        )
      ]
      contact_roles = try(notification.value.contact_roles, [])
    }
  }
}

# Rule for Quota Alert to monitor the quota metrics at the subscription level and send notifications when the specified threshold is reached
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "quota" {
  count = var.quota_alert != null ? 1 : 0

  name                             = var.quota_alert.name
  resource_group_name              = local.resource_group_name
  location                         = var.quota_alert.location
  display_name                     = var.quota_alert.display_name
  description                      = try(var.quota_alert.description, null)
  enabled                          = var.quota_alert.enabled
  auto_mitigation_enabled          = var.quota_alert.auto_mitigation_enabled
  evaluation_frequency             = var.quota_alert.evaluation_frequency
  scopes                           = var.quota_alert.scopes
  severity                         = var.quota_alert.severity
  skip_query_validation            = var.quota_alert.skip_query_validation
  target_resource_types            = var.quota_alert.target_resource_types
  window_duration                  = var.quota_alert.window_duration
  workspace_alerts_storage_enabled = var.quota_alert.workspace_alerts_storage_enabled

  criteria {
    metric_measure_column   = var.quota_alert.criteria.metric_measure_column
    operator                = var.quota_alert.criteria.operator
    query                   = var.quota_alert.criteria.query
    threshold               = var.quota_alert.criteria.threshold
    time_aggregation_method = var.quota_alert.criteria.time_aggregation_method

    dynamic "dimension" {
      for_each = var.quota_alert.criteria.dimension
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }

    failing_periods {
      minimum_failing_periods_to_trigger_alert = var.quota_alert.criteria.failing_periods.minimum_failing_periods_to_trigger_alert
      number_of_evaluation_periods             = var.quota_alert.criteria.failing_periods.number_of_evaluation_periods
    }
  }

  identity {
    type         = var.quota_alert.identity.type
    identity_ids = length(azurerm_user_assigned_identity.quota_alert_reader) > 0 ? [azurerm_user_assigned_identity.quota_alert_reader[0].id] : var.quota_alert.identity.identity_ids
  }

  action {
    action_groups = local.quota_action_group_ids
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = var.identity != null || length(coalesce(var.quota_alert.identity.identity_ids, [])) > 0
      error_message = "When quota_alert is set, either var.identity must be configured (to let the module create a managed identity) or quota_alert.identity.identity_ids must be provided with at least one identity ID."
    }

    precondition {
      condition     = length(local.quota_action_group_ids) > 0
      error_message = "When quota_alert is set, configure at least one action_group entry or provide quota_alert.action_groups explicitly."
    }
  }
}

# Activity Log Alerts to monitor the activity logs at the subscription level and send notifications when the specified conditions are met
## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert
resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = { for idx, alert in var.log_alert : alert.name => alert }

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
  }
}

# Alert Processing Rule to suppress the alerts during the backup window
resource "azurerm_monitor_alert_processing_rule_action_group" "backup" {
  count = var.backup_alert != null ? 1 : 0

  name                 = var.backup_alert.name
  resource_group_name  = coalesce(var.backup_alert.resource_group_name, local.resource_group_name)
  scopes               = var.backup_alert.scopes
  description          = try(var.backup_alert.description, null)
  add_action_group_ids = var.backup_alert.add_action_group_ids

  tags = local.tags
}
