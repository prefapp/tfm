# Variables for the Azure Role Assignment module
variable "role_assignments" {
  description = "Map of role assignments to create. Each map key is an arbitrary assignment name (used only by Terraform); each value must include scope, target_id, optional principal type, and exactly one of role_definition_name or role_definition_id."
  type = map(object({
    scope                  = string
    target_id              = string
    type                   = optional(string, "ServicePrincipal")
    role_definition_name   = optional(string)
    role_definition_id     = optional(string)
  }))

  validation {
    condition = alltrue([
      for k, v in var.role_assignments : (
        (v.role_definition_name != null && v.role_definition_id == null) ||
        (v.role_definition_name == null && v.role_definition_id != null)
      )
    ])
    error_message = "Each role assignment must set exactly one of 'role_definition_name' or 'role_definition_id' (not both, not neither)."
  }

  validation {
    condition = alltrue([
      for k, v in var.role_assignments : (
        v.type == "ServicePrincipal" || v.type == "User" || v.type == "Group"
      )
    ])
    error_message = "The 'type' field must be one of 'ServicePrincipal', 'User', or 'Group'."
  }

  default = {}
}
