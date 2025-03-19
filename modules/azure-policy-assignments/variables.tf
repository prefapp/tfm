# VARIABLES SECTION
variable "assignments" {
  description = "List of objects containing all the variables for the policy assignments."
  type = list(object({
    name                  = string
    policy_type           = optional(string, "builtin")
    policy_name           = optional(string)
    policy_definition_id  = optional(string)
    resource_id           = optional(string)
    resource_group_id     = optional(string)
    management_group_id   = optional(string)
    resource_group_name   = optional(string)
    management_group_name = optional(string)
    scope                 = string
    description           = optional(string)
    display_name          = optional(string)
    enforce               = optional(bool, true)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    location = optional(string)
    metadata = optional(string)
    non_compliance_message = optional(list(object({
      content                        = string
      policy_definition_reference_id = optional(string)
    })))
    not_scopes = optional(list(string))
    parameters = optional(map(any))
    overrides = optional(list(object({
      value = string
      selectors = optional(list(object({
        in     = optional(list(string))
        not_in = optional(list(string))
      })))
    })))
    resource_selectors = optional(list(object({
      name = optional(string)
      selectors = list(object({
        kind   = string
        in     = optional(list(string))
        not_in = optional(list(string))
      }))
    })))
  }))
  default = []
  validation {
    condition = alltrue([
      for assignment in var.assignments : contains(["builtin", "custom"], assignment.policy_type)
    ])
    error_message = "policy_type can only be 'builtin' or 'custom'."
  }
}
