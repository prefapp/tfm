terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "config" {
  description = "GitHub team configuration as a single complex object"
  type = object({
    group = object({
      name         = string
      description  = optional(string, "")
      privacy      = optional(string, "closed")
      parentTeamId = optional(number, null)   # null or team ID (number)
    })

    group_members = optional(list(object({
      username = string
      teamId   = optional(string)   # kept for compatibility, ignored during creation
    })), [])
  })

  # ─── Validations ─────────────────────────────────────────────────────
  validation {
    condition     = contains(["closed", "secret"], var.config.group.privacy)
    error_message = "group.privacy must be 'closed' or 'secret'."
  }

  validation {
    condition     = length(trimspace(var.config.group.name)) > 0
    error_message = "group.name cannot be empty."
  }

  validation {
    condition = alltrue([
      for m in var.config.group_members : length(trimspace(m.username)) > 0
    ])
    error_message = "Every member in group_members must have a non-empty username."
  }
}
