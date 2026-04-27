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
      for name in sort([for receiver in values(coalesce(try(each.value.arm_role_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.arm_role_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name                    = arm_role_receiver.key
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = try(arm_role_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "automation_runbook_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.automation_runbook_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.automation_runbook_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name                    = automation_runbook_receiver.key
      automation_account_id   = automation_runbook_receiver.value.automation_account_id
      runbook_name            = automation_runbook_receiver.value.runbook_name
      webhook_resource_id     = try(automation_runbook_receiver.value.webhook_resource_id, null)
      service_uri             = try(automation_runbook_receiver.value.service_uri, null)
      is_global_runbook       = try(automation_runbook_receiver.value.is_global_runbook, false)
      use_common_alert_schema = try(automation_runbook_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "azure_app_push_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.azure_app_push_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.azure_app_push_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name          = azure_app_push_receiver.key
      email_address = azure_app_push_receiver.value.email_address
    }
  }

  dynamic "azure_function_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.azure_function_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.azure_function_receivers, null), {})) : receiver if receiver.name == name][0]
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
      for name in sort([for receiver in values(coalesce(try(each.value.email_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.email_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = try(email_receiver.value.use_common_alert_schema, true)
    }
  }

  dynamic "event_hub_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.event_hub_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.event_hub_receivers, null), {})) : receiver if receiver.name == name][0]
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
      for name in sort([for receiver in values(coalesce(try(each.value.itsm_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.itsm_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name                 = itsm_receiver.key
      workspace_id         = itsm_receiver.value.workspace_id
      connection_id        = itsm_receiver.value.connection_id
      region               = try(itsm_receiver.value.region, null)
      ticket_configuration = try(itsm_receiver.value.ticket_configuration, null)
    }
  }

  dynamic "logic_app_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.logic_app_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.logic_app_receivers, null), {})) : receiver if receiver.name == name][0]
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
      for name in sort([for receiver in values(coalesce(try(each.value.sms_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.sms_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name         = sms_receiver.key
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "voice_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.voice_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.voice_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name         = voice_receiver.key
      country_code = voice_receiver.value.country_code
      phone_number = voice_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = {
      for name in sort([for receiver in values(coalesce(try(each.value.webhook_receivers, null), {})) : receiver.name]) : name =>
      [for receiver in values(coalesce(try(each.value.webhook_receivers, null), {})) : receiver if receiver.name == name][0]
    }
    content {
      name                    = webhook_receiver.key
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = try(webhook_receiver.value.use_common_alert_schema, true)

      dynamic "aad_auth" {
        for_each = try(webhook_receiver.value.aad_auth, null) != null ? [webhook_receiver.value.aad_auth] : []
        content {
          object_id      = aad_auth.value.object_id
          identifier_uri = try(aad_auth.value.identifier_uri, null)
          tenant_id      = aad_auth.value.tenant_id
        }
      }
    }
  }

  tags = local.tags
}