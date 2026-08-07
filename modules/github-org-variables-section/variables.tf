variable "config" {
  description = <<-EOT
    Complete configuration object for this module.

    variables = map of variable_name => { value, visibility, selectedRepositoryIds }

    - variable_name (map key): GitHub Actions organization variable name. Must match ^[A-Za-z0-9_]+$.
    - value: The value of the variable.
    - visibility: Must be one of 'all', 'private', or 'selected'.
    - selectedRepositoryIds: Optional list of repository full names (owner/repo) to scope the variable to when visibility is 'selected'. Ignored for other visibility modes.
  EOT

  type = object({
    variables = map(object({
      value                 = string
      visibility            = string
      selectedRepositoryIds = optional(list(string))
    }))
  })

  validation {
    condition = alltrue([
      for key in keys(var.config.variables) :
      can(regex("^[A-Za-z0-9_]+$", key))
    ])
    error_message = "Variable names (map keys) must contain only letters, digits, and underscores."
  }

  validation {
    condition = alltrue([
      for v in values(var.config.variables) :
      contains(["all", "private", "selected"], v.visibility)
    ])
    error_message = "visibility must be one of: all, private, selected."
  }

  validation {
    condition = alltrue([
      for v in values(var.config.variables) :
      trimspace(v.value) != ""
    ])
    error_message = "All variable values must be non-empty strings."
  }

  nullable = false
}
