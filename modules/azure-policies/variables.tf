# VARIABLES SECTION
variable "policies" {
  description = "List of objects containing all the variables for the policy definitions."
  type = list(object({
    name                = string
    policy_type         = string
    mode                = string
    display_name        = string
    description         = optional(string)
    management_group_id = optional(string)
    policy_rule         = optional(string)
    metadata            = optional(string)
    parameters          = optional(string)
  }))
  default = []
}

variable "assignments" {
  description = "List of objects containing all the variables for the policy assignments."
  type = list(object({
    name                 = string
    policy_name          = optional(string)
    policy_definition_id = optional(string)
    resource_id          = string
    scope                = string
    description          = optional(string)
    display_name         = optional(string)
    enforce              = optional(bool, true)
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
    parameters = optional(string)
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
}
