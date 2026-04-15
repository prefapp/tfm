# Common variables for the module
variable "common" {
  type = object({
    location            = optional(string, "westeurope")
    resource_group_name = optional(string, null)
    tags                = optional(map(string), {})
    tags_from_rg        = optional(bool, false)
  })
  default = {} # both fields have defaults, so the entire block is optional
}

# Identity for Quota Alert
variable "identity" {
  type = object({
    name                 = string
    scope                = string
    role_definition_name = optional(string, "Reader")
  })
  default = null # null = do not create a managed identity or role assignment

  validation {
    condition = var.identity == null || length(
      var.quota_alert == null ? [] : (
        can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
        ? values(tomap({ (var.quota_alert.name) = var.quota_alert }))
        : values(tomap(var.quota_alert))
      )
    ) > 0
    error_message = "The identity variable can only be set when at least one quota_alert entry is configured."
  }
}

# Action Group(s)
variable "action_group" {
  description = "Optional map of Azure Monitor Action Groups keyed by logical name. Can contain zero or more entries."
  type = map(object({
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
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, ag in var.action_group : length(ag.short_name) > 0 && length(ag.short_name) <= 12
    ])
    error_message = "Each action_group.short_name must be 1 to 12 characters."
  }

  validation {
    condition = alltrue([
      for _, ag in var.action_group : alltrue([
        length(toset([for v in values(ag.arm_role_receivers) : v.name])) == length([for v in values(ag.arm_role_receivers) : v.name]),
        length(toset([for v in values(ag.automation_runbook_receivers) : v.name])) == length([for v in values(ag.automation_runbook_receivers) : v.name]),
        length(toset([for v in values(ag.azure_app_push_receivers) : v.name])) == length([for v in values(ag.azure_app_push_receivers) : v.name]),
        length(toset([for v in values(ag.azure_function_receivers) : v.name])) == length([for v in values(ag.azure_function_receivers) : v.name]),
        length(toset([for v in values(ag.email_receivers) : v.name])) == length([for v in values(ag.email_receivers) : v.name]),
        length(toset([for v in values(ag.event_hub_receivers) : v.name])) == length([for v in values(ag.event_hub_receivers) : v.name]),
        length(toset([for v in values(ag.itsm_receivers) : v.name])) == length([for v in values(ag.itsm_receivers) : v.name]),
        length(toset([for v in values(ag.logic_app_receivers) : v.name])) == length([for v in values(ag.logic_app_receivers) : v.name]),
        length(toset([for v in values(ag.sms_receivers) : v.name])) == length([for v in values(ag.sms_receivers) : v.name]),
        length(toset([for v in values(ag.voice_receivers) : v.name])) == length([for v in values(ag.voice_receivers) : v.name]),
        length(toset([for v in values(ag.webhook_receivers) : v.name])) == length([for v in values(ag.webhook_receivers) : v.name])
      ])
    ])
    error_message = "Each receiver type in action_group must use unique receiver 'name' values to avoid ordering collisions."
  }

  validation {
    condition = length(distinct([
      for _, ag in var.action_group : "${ag.resource_group_name}/${ag.name}"
    ])) == length(var.action_group)
    error_message = "Each action_group entry must have a unique (resource_group_name, name) combination. Duplicate pairs would cause a key collision in the internal reference map."
  }
}

# Budget Alert
variable "budget" {
  description = "Budget alert configuration(s). Accepts either a legacy single object or a map of objects keyed by logical name."
  type        = any
  default     = {}

  validation {
    condition = var.budget == null || can(
      var.budget.notification
      ) || can(
      tomap(var.budget)
    )
    error_message = "budget must be either a single budget object or a map of budget objects."
  }

  validation {
    condition = alltrue([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? [var.budget]
          : [for _, b in tomap(var.budget) : b]
        )
      ) : try(length(budget.notification), 0) > 0
    ])
    error_message = "Each budget entry must contain at least one notification block."
  }

  validation {
    condition = alltrue([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? [var.budget]
          : [for _, b in tomap(var.budget) : b]
        )
      ) : try(budget.name, null) != null
    ]) && length(distinct([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? [var.budget]
          : [for _, b in tomap(var.budget) : b]
        )
      ) : try(budget.name, null)
    ])) == length([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? [var.budget]
          : [for _, b in tomap(var.budget) : b]
        )
      ) : try(budget.name, null)
    ])
    error_message = "Each budget.name must be unique."
  }

  validation {
    condition = alltrue(flatten([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? [var.budget]
          : [for _, b in tomap(var.budget) : b]
        )
        ) : [
        for n in try(budget.notification, []) : [
          for g in try(n.contact_groups, []) : (
            can(tostring(g)) || (
              can(g.name) &&
              try(g.name, null) != null &&
              trimspace(try(g.name, "")) != "" &&
              (
                !can(g.resource_group_name) ||
                (
                  try(g.resource_group_name, null) != null &&
                  trimspace(try(g.resource_group_name, "")) != ""
                )
              )
            )
          )
        ]
      ]
    ]))
    error_message = "Each budget.notification[*].contact_groups entry must be either a string (Action Group name or full resource ID) or an object with a non-empty 'name' attribute; if 'resource_group_name' is provided, it must also be non-empty."
  }
}

# Quota Alert (Scheduled Query Rules V2)
variable "quota_alert" {
  description = "Quota alert configuration(s). Accepts either a legacy single object or a map of objects keyed by logical name."
  type        = any
  default     = {}

  validation {
    condition = var.quota_alert == null || can(
      var.quota_alert.criteria
      ) || can(
      tomap(var.quota_alert)
    )
    error_message = "quota_alert must be either a single quota alert object or a map of quota alert objects."
  }

  validation {
    condition = alltrue([
      for _, quota in(
        var.quota_alert == null ? {} : (
          can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
          ? { (var.quota_alert.name) = var.quota_alert }
          : { for _, q in tomap(var.quota_alert) : q.name => q }
        )
        ) : contains(
        ["UserAssigned", "SystemAssigned, UserAssigned"],
        quota.identity.type
      )
    ])
    error_message = "Each quota_alert.identity.type must be \"UserAssigned\" or \"SystemAssigned, UserAssigned\"."
  }

  validation {
    condition = length(distinct([
      for _, quota in(
        var.quota_alert == null ? {} : (
          can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
          ? { (var.quota_alert.name) = var.quota_alert }
          : { for _, q in tomap(var.quota_alert) : q.name => q }
        )
      ) : quota.name
      ])) == length([
      for _, quota in(
        var.quota_alert == null ? {} : (
          can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
          ? { (var.quota_alert.name) = var.quota_alert }
          : { for _, q in tomap(var.quota_alert) : q.name => q }
        )
      ) : quota.name
    ])
    error_message = "Each quota_alert.name must be unique."
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
      action_group       = optional(any, null)
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

  validation {
    condition     = length(toset([for alert in var.log_alert : alert.name])) == length(var.log_alert)
    error_message = "Each log_alert.name must be unique."
  }
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
