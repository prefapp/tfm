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
        : can(tolist(var.quota_alert))
        ? [for quota in tolist(var.quota_alert) : quota]
        : values(tomap(var.quota_alert))
      )
    ) > 0
    error_message = "The identity variable can only be set when at least one quota_alert entry is configured."
  }
}

# Action Group(s)
variable "action_group" {
  description = "Action Group configuration(s). Accepts a list (preferred), a map (legacy), or a single object."
  type        = any
  default     = []

  validation {
    condition = var.action_group == null || (
      (can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)) ||
      can(tolist(var.action_group)) ||
      can(tomap(var.action_group))
    )
    error_message = "action_group must be a single object, a list of objects, or a map of objects."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
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
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : ag.name
      ])) == length([
      for ag in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for a in tolist(var.action_group) : a]
          : [for _, a in tomap(var.action_group) : a]
        )
      ) : ag.name
    ])
    error_message = "Each action_group.name must be unique."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for item in tolist(var.action_group) : item]
          : [for _, item in tomap(var.action_group) : item]
        )
      ) : length(ag.short_name) > 0 && length(ag.short_name) <= 12
    ])
    error_message = "Each action_group.short_name must be 1 to 12 characters."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for item in tolist(var.action_group) : item]
          : [for _, item in tomap(var.action_group) : item]
        )
        ) : alltrue([
          length(toset([for v in values(coalesce(try(ag.arm_role_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.arm_role_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.automation_runbook_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.automation_runbook_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.azure_app_push_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.azure_app_push_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.azure_function_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.azure_function_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.email_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.email_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.event_hub_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.event_hub_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.itsm_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.itsm_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.logic_app_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.logic_app_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.sms_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.sms_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.voice_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.voice_receivers, null), {})) : v.name]),
          length(toset([for v in values(coalesce(try(ag.webhook_receivers, null), {})) : v.name])) == length([for v in values(coalesce(try(ag.webhook_receivers, null), {})) : v.name])
      ])
    ])
    error_message = "Each receiver type in action_group must use unique receiver 'name' values to avoid ordering collisions."
  }

  validation {
    condition = length(distinct([
      for ag in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for item in tolist(var.action_group) : item]
          : [for _, item in tomap(var.action_group) : item]
        )
      ) : "${ag.resource_group_name}/${ag.name}"
      ])) == length({
      for idx, a in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for item in tolist(var.action_group) : item]
          : [for _, item in tomap(var.action_group) : item]
        )
      ) : idx => a
    })
    error_message = "Each action_group entry must have a unique (resource_group_name, name) combination. Duplicate pairs would cause a key collision in the internal reference map."
  }

  validation {
    condition = alltrue([
      for ag in(
        var.action_group == null ? [] : (
          can(var.action_group.name) && can(var.action_group.short_name) && can(var.action_group.resource_group_name)
          ? values(tomap({ (var.action_group.name) = var.action_group }))
          : can(tolist(var.action_group))
          ? [for item in tolist(var.action_group) : item]
          : [for _, item in tomap(var.action_group) : item]
        )
        ) : (
        try(ag.resource_group_name, null) != null && trimspace(try(ag.resource_group_name, "")) != ""
      )
    ])
    error_message = "Each action_group entry must define a non-empty resource_group_name."
  }
}

# Budget Alert
variable "budget" {
  description = "Budget alert configuration(s). Accepts a list (preferred), a map (legacy), or a single object."
  type        = any
  default     = []

  validation {
    condition = var.budget == null || can(
      var.budget.notification
      ) || can(
      tolist(var.budget)
      ) || can(
      tomap(var.budget)
    )
    error_message = "budget must be a single budget object, a list of budget objects, or a map of budget objects."
  }

  validation {
    condition = alltrue([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? values(tomap({ (var.budget.name) = var.budget }))
          : can(tolist(var.budget))
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
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? values(tomap({ (var.budget.name) = var.budget }))
          : can(tolist(var.budget))
          ? [for b in tolist(var.budget) : b]
          : [for _, b in tomap(var.budget) : b]
        )
      ) : try(budget.name, null) != null
      ]) && length(distinct([
        for budget in(
          var.budget == null ? [] : (
            can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
            ? values(tomap({ (var.budget.name) = var.budget }))
            : can(tolist(var.budget))
            ? [for b in tolist(var.budget) : b]
            : [for _, b in tomap(var.budget) : b]
          )
        ) : try(budget.name, null)
      ])) == length([
      for budget in(
        var.budget == null ? [] : (
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? values(tomap({ (var.budget.name) = var.budget }))
          : can(tolist(var.budget))
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
          can(var.budget.notification) && can(var.budget.time_period) && can(var.budget.time_grain) && can(var.budget.amount)
          ? values(tomap({ (var.budget.name) = var.budget }))
          : can(tolist(var.budget))
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
  description = "Quota alert configuration(s). Accepts a list (preferred), a map (legacy), or a single object."
  type        = any
  default     = []

  validation {
    condition = var.quota_alert == null || can(
      var.quota_alert.criteria
      ) || can(
      tolist(var.quota_alert)
      ) || can(
      tomap(var.quota_alert)
    )
    error_message = "quota_alert must be a single quota alert object, a list of quota alert objects, or a map of quota alert objects."
  }

  validation {
    condition = alltrue([
      for quota in(
        var.quota_alert == null ? [] : (
          can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
          ? values(tomap({ (var.quota_alert.name) = var.quota_alert }))
          : can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
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
      for quota in(
        var.quota_alert == null ? [] : (
          can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
          ? values(tomap({ (var.quota_alert.name) = var.quota_alert }))
          : can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
        )
      ) : quota.name
      ])) == length([
      for quota in(
        var.quota_alert == null ? [] : (
          can(var.quota_alert.criteria) && can(var.quota_alert.identity) && can(var.quota_alert.scopes) && can(var.quota_alert.name)
          ? values(tomap({ (var.quota_alert.name) = var.quota_alert }))
          : can(tolist(var.quota_alert))
          ? [for q in tolist(var.quota_alert) : q]
          : [for _, q in tomap(var.quota_alert) : q]
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

# Backup Alert Processing Rule(s)
variable "backup_alert" {
  description = "Backup alert processing rule configuration(s). Accepts a list (preferred), a map (legacy), or a single object."
  type        = any
  default     = []

  validation {
    condition = var.backup_alert == null || (
      (can(var.backup_alert.name) && can(var.backup_alert.scopes)) ||
      can(tolist(var.backup_alert)) ||
      can(tomap(var.backup_alert))
    )
    error_message = "backup_alert must be a single object, a list of objects, or a map of objects."
  }

  validation {
    condition = alltrue([
      for alert in(
        var.backup_alert == null ? [] : (
          can(var.backup_alert.name) && can(var.backup_alert.scopes)
          ? values(tomap({ (var.backup_alert.name) = var.backup_alert }))
          : can(tolist(var.backup_alert))
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
          can(var.backup_alert.name) && can(var.backup_alert.scopes)
          ? values(tomap({ (var.backup_alert.name) = var.backup_alert }))
          : can(tolist(var.backup_alert))
          ? [for a in tolist(var.backup_alert) : a]
          : [for _, a in tomap(var.backup_alert) : a]
        )
      ) : alert.name
      ])) == length([
      for alert in(
        var.backup_alert == null ? [] : (
          can(var.backup_alert.name) && can(var.backup_alert.scopes)
          ? values(tomap({ (var.backup_alert.name) = var.backup_alert }))
          : can(tolist(var.backup_alert))
          ? [for a in tolist(var.backup_alert) : a]
          : [for _, a in tomap(var.backup_alert) : a]
        )
      ) : alert.name
    ])
    error_message = "Each backup_alert.name must be unique."
  }
}
