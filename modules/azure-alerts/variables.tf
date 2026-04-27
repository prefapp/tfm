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
        can(tolist(var.quota_alert))
        ? [for quota in tolist(var.quota_alert) : quota]
        : values(tomap(var.quota_alert))
      )
    ) > 0
    error_message = "The identity variable can only be set when at least one quota_alert entry is configured."
  }
}

# Action Group(s)
variable "action_group" {
  description = "Action Group configuration(s). Accepts a list of objects (preferred) or a legacy map of objects."
  type        = any
  default     = []

  validation {
    condition     = var.action_group == null || can(tolist(var.action_group)) || can(tomap(var.action_group))
    error_message = "action_group must be a list of objects or a map of objects."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : try(ag.name, null) != null && trimspace(try(ag.name, "")) != ""
    ])
    error_message = "Each action_group entry must define a non-empty name."
  }

  validation {
    condition = length(distinct([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : try(ag.name, null) if try(ag.name, null) != null
      ])) == length([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : try(ag.name, null) if try(ag.name, null) != null
    ])
    error_message = "Each action_group.name must be unique."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : length(coalesce(try(ag.short_name, null), "")) > 0 && length(coalesce(try(ag.short_name, null), "")) <= 12
    ])
    error_message = "Each action_group.short_name must be 1 to 12 characters."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
        ) : alltrue([
          length(toset([for v in values(coalesce(try(ag.arm_role_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.arm_role_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.automation_runbook_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.automation_runbook_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.azure_app_push_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.azure_app_push_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.azure_function_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.azure_function_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.email_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.email_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.event_hub_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.event_hub_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.itsm_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.itsm_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.logic_app_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.logic_app_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.sms_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.sms_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.voice_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.voice_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null]),
          length(toset([for v in values(coalesce(try(ag.webhook_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])) == length([for v in values(coalesce(try(ag.webhook_receivers, null), {})) : try(v.name, null) if try(v.name, null) != null])
      ])
    ])
    error_message = "Each receiver type in action_group must use unique receiver 'name' values to avoid ordering collisions."
  }

  validation {
    condition = length(distinct([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : "${ag.resource_group_name}/${ag.name}"
      ])) == length([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : "${ag.resource_group_name}/${ag.name}"
    ])
    error_message = "Each action_group entry must have a unique (resource_group_name, name) combination."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : try(ag.resource_group_name, null) != null && trimspace(try(ag.resource_group_name, "")) != ""
    ])
    error_message = "Each action_group entry must define a non-empty resource_group_name."
  }
}

# Budget Alert
variable "budget" {
  description = "Budget alert configuration(s). Accepts a list of objects (preferred) or a legacy map of objects."
  type        = any
  default     = []

  validation {
    condition     = var.budget == null || can(tolist(var.budget)) || can(tomap(var.budget))
    error_message = "budget must be a list of budget objects or a map of budget objects."
  }

  validation {
    condition = alltrue([
      for budget in(
        var.budget == null ? [] : (
          can(tolist(var.budget))
          ? [for b in tolist(var.budget) : b]
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
          can(tolist(var.budget))
          ? [for b in tolist(var.budget) : b]
          : [for _, b in tomap(var.budget) : b]
        )
      ) : (
        try(budget.name, null) != null &&
        trimspace(try(budget.name, "")) != ""
      )
      ]) && length(distinct([
        for budget in(
          var.budget == null ? [] : (
            can(tolist(var.budget))
            ? [for b in tolist(var.budget) : b]
            : [for _, b in tomap(var.budget) : b]
          )
        ) : try(budget.name, null)
      ])) == length([
      for budget in(
        var.budget == null ? [] : (
          can(tolist(var.budget))
          ? [for b in tolist(var.budget) : b]
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
          can(tolist(var.budget))
          ? [for b in tolist(var.budget) : b]
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
  description = "Quota alert configuration(s). Accepts a list of objects (preferred) or a legacy map of objects."
  type        = any
  default     = []

  validation {
    condition     = var.quota_alert == null || can(tolist(var.quota_alert)) || can(tomap(var.quota_alert))
    error_message = "quota_alert must be a list of quota alert objects or a map of quota alert objects."
  }

  validation {
    condition = alltrue([
      for quota in(
        var.quota_alert == null ? [] : (
          can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
        )
        ) : try(contains(
        ["UserAssigned", "SystemAssigned, UserAssigned"],
        quota.identity.type
      ), false)
    ])
    error_message = "Each quota_alert.identity.type must be \"UserAssigned\" or \"SystemAssigned, UserAssigned\"."
  }

  validation {
    condition = alltrue([
      for quota in(
        var.quota_alert == null ? [] : (
          can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
        )
      ) : (
        try(quota.name, null) != null &&
        trimspace(try(quota.name, "")) != ""
      )
    ])
    error_message = "Each quota_alert entry must have a non-empty 'name' attribute."
  }

  validation {
    condition = length(distinct([
      for quota in(
        var.quota_alert == null ? [] : (
          can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
        )
      ) : try(quota.name, null)
      ])) == length([
      for quota in(
        var.quota_alert == null ? [] : (
          can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
        )
      ) : try(quota.name, null)
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

# Backup Alert Processing Rule(s)
variable "backup_alert" {
  description = "Backup alert processing rule configuration(s). Accepts a list of objects (preferred) or a legacy map of objects."
  type        = any
  default     = []

  validation {
    condition     = var.backup_alert == null || can(tolist(var.backup_alert)) || can(tomap(var.backup_alert))
    error_message = "backup_alert must be a list of objects or a map of objects."
  }

  validation {
    condition = alltrue([
      for alert in(
        var.backup_alert == null ? [] : (
          can(tolist(var.backup_alert))
          ? [for a in tolist(var.backup_alert) : a]
          : [for _, a in tomap(var.backup_alert) : a]
        )
      ) : try(alert.name, null) != null && trimspace(try(alert.name, "")) != ""
    ])
    error_message = "Each backup_alert entry must define a non-empty name."
  }

  validation {
    condition = length(distinct([
      for alert in(
        var.backup_alert == null ? [] : (
          can(tolist(var.backup_alert))
          ? [for a in tolist(var.backup_alert) : a]
          : [for _, a in tomap(var.backup_alert) : a]
        )
      ) : try(alert.name, null) if try(alert.name, null) != null
      ])) == length([
      for alert in(
        var.backup_alert == null ? [] : (
          can(tolist(var.backup_alert))
          ? [for a in tolist(var.backup_alert) : a]
          : [for _, a in tomap(var.backup_alert) : a]
        )
      ) : try(alert.name, null) if try(alert.name, null) != null
    ])
    error_message = "Each backup_alert.name must be unique."
  }
}
