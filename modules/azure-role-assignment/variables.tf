# Variables for the Azure Role Assignment module
variable "role_assignments" {
  description = "A map of role assignments to create. The key is the scope, and the value is a map containing the role definition name and target ID."
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
    target_id            = string
  }))

  validation {
    condition = alltrue([
      for k, v in var.role_assignments : (
        !(v.role_definition_name != null && v.role_definition_id != null)
      )
    ])
    error_message = "Each role assignment must have either 'role_definition_name' or 'role_definition_id', but not both."
  }
  default = {}
}
