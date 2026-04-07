# Common variables for the module
variable "common" {
  type = object({
    location            = optional(string, "westeurope")
    resource_group_name = optional(string, null)
    tags                = optional(map(string), {})
    tags_from_rg        = optional(bool, false)
  })
  default = {} # ambos campos tienen default → el bloque entero es opcional
}

# Identity for Quota Alert
variable "identity" {
  type = object({
    name                 = string
    scope                = string
    role_definition_name = optional(string, "Reader")
  })
  default = null # null = no crear MI ni role assignment
}

# Action Group
variable "action_group" {
  description = "Configuration for the Azure Monitor Action Group."
  type = object({
    name                = string
    resource_group_name = string
    short_name          = string
    arm_role_receivers = optional(map(object({
      name                    = string
      role_id                 = string
      use_common_alert_schema = optional(bool, true)
    })), {})
    automation_runbook_receivers = optional(map(object({
      name                    = string
      automation_account_id   = string
      runbook_name            = string
      webhook_resource_id     = optional(string, null)
      service_uri             = optional(string, null)
      is_global_runbook       = optional(bool, false)
      use_common_alert_schema = optional(bool, true)
    })), {})
    azure_app_push_receivers = optional(map(object({
      name          = string
      email_address = string
    })), {})
    azure_function_receivers = optional(map(object({
      name                     = string
      function_app_resource_id = string
      function_name            = string
      http_trigger_url         = string
      use_common_alert_schema  = optional(bool, true)
    })), {})
    email_receivers = optional(map(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = optional(bool, true)
    })), {})
    event_hub_receivers = optional(map(object({
      name                    = string
      event_hub_name          = string
      event_hub_namespace     = string
      use_common_alert_schema = optional(bool, true)
    })), {})
    itsm_receivers = optional(map(object({
      name                 = string
      workspace_id         = string
      connection_id        = string
      region               = optional(string, null)
      ticket_configuration = optional(string, null)
    })), {})
    logic_app_receivers = optional(map(object({
      name                    = string
      resource_id             = string
      callback_url            = string
      use_common_alert_schema = optional(bool, true)
    })), {})
    sms_receivers = optional(map(object({
      name         = string
      country_code = string
      phone_number = string
    })), {})
    voice_receivers = optional(map(object({
      name         = string
      country_code = string
      phone_number = string
    })), {})
    webhook_receivers = optional(map(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = optional(bool, true)
      aad_auth = optional(object({
        object_id      = string
        identifier_uri = optional(string, null)
        tenant_id      = string
      }), null)
    })), {})
  })

  validation {
    condition     = length(var.action_group.short_name) <= 12
    error_message = "action_group.short_name must be 12 characters or fewer."
  }
}

# Budget Alert
variable "budget" {
  description = "Configuration for the subscription consumption budget alert. Set to null to disable."
  type = object({
    name            = string
    subscription_id = string
    amount          = number
    time_grain      = string
    time_period = object({
      start_date = string
      end_date   = optional(string)
    })
    notification = list(object({
      enabled        = bool
      operator       = string
      threshold      = number
      threshold_type = optional(string, "Actual")
      contact_emails = list(string)
      contact_groups = optional(list(string), [])
      contact_roles  = optional(list(string), [])
    }))
  })
  default = null
}

# Quota Alert (Scheduled Query Rules V2)
variable "quota_alert" {
  description = "Configuration for the quota scheduled query rules alert. Set to null to disable."
  type = object({
    auto_mitigation_enabled          = optional(bool, true)
    display_name                     = string
    description                      = optional(string)
    enabled                          = optional(bool, true)
    evaluation_frequency             = string
    location                         = string
    name                             = string
    scopes                           = list(string)
    severity                         = number
    skip_query_validation            = optional(bool, false)
    target_resource_types            = optional(list(string), [])
    window_duration                  = string
    workspace_alerts_storage_enabled = optional(bool, false)
    criteria = object({
      metric_measure_column   = string
      operator                = string
      query                   = string
      threshold               = number
      time_aggregation_method = string
      dimension = list(object({
        name     = string
        operator = string
        values   = list(string)
      }))
      failing_periods = object({
        minimum_failing_periods_to_trigger_alert = number
        number_of_evaluation_periods             = number
      })
    })
    identity = object({
      type         = string
      identity_ids = optional(list(string), [])
    })
  })
  default = null

  validation {
    condition = var.quota_alert == null || contains(
      ["UserAssigned", "SystemAssigned, UserAssigned"],
      var.quota_alert.identity.type
    )
    error_message = "quota_alert.identity.type must be \"UserAssigned\" or \"SystemAssigned, UserAssigned\" when this module manages and assigns a user-assigned identity."
  }
}

# Activity Log Alerts
variable "log_alert" {
  description = "List of activity log alert configurations. Set to empty list to disable."
  type = list(object({
    name                = string
    resource_group_name = optional(string, null)
    location            = optional(string, "global")
    description         = optional(string)
    enabled             = optional(bool, true)
    scopes              = list(string)
    action = object({
      action_group_id    = optional(string, null)
      webhook_properties = optional(map(string), {})
    })
    criteria = object({
      category           = string
      levels             = optional(list(string), [])
      resource_groups    = optional(list(string), [])
      resource_ids       = optional(list(string), [])
      resource_providers = optional(list(string), [])
      resource_types     = optional(list(string), [])
      statuses           = optional(list(string), [])
      sub_statuses       = optional(list(string), [])
      service_health = optional(object({
        events    = optional(list(string), [])
        locations = optional(list(string), [])
        services  = optional(list(string), [])
      }))
    })
  }))
  default = []
}

# Backup Alert Processing Rule
variable "backup_alert" {
  description = "Configuration for the alert processing rule action group (e.g. backup alerts). Set to null to disable."
  type = object({
    name                 = string
    resource_group_name  = optional(string, null)
    scopes               = list(string)
    description          = optional(string)
    add_action_group_ids = list(string)
  })
  default = null
}
