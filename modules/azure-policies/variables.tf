# VARIABLES SECTION
variable "policy" {
  description = "Object containing all the variables for the policy definition."
  type = object({
    name                = string
    policy_type         = string
    mode                = string
    display_name        = string
    description         = optional(string)
    management_group_id = optional(string)
    policy_rule         = optional(string)
    metadata            = optional(string)
    parameters          = optional(string)
  })
  validation {
    condition = alltrue([
      contains(["BuiltIn", "Custom", "NotSpecified", "Static"], var.policy.policy_type),
      contains(["All", "Indexed", "Microsoft.ContainerService.Data", "Microsoft.CustomerLockbox.Data", "Microsoft.DataCatalog.Data", "Microsoft.KeyVault.Data", "Microsoft.Kubernetes.Data", "Microsoft.MachineLearningServices.Data", "Microsoft.Network.Data", "Microsoft.Synapse.Data"], var.policy_definition.mode)
    ])
    error_message = "Invalid value for policy_type or mode."
  }
}

variable "assignments" {
  description = "Object containing all the variables for the policy assignment."
  type = object({
    name                 = string
    policy_definition_id = string
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
  })
  validation {
    condition = alltrue([
      length(var.assignments.name) <= 64,
      contains(["SystemAssigned", "UserAssigned"], var.assignments.identity.type)
    ])
    error_message = "Invalid value for name length or identity type."
  }

  validation {
    condition     = can(var.assignments.identity) ? can(var.assignments.location) : true
    error_message = "The location field must also be specified when identity is specified."
  }

  validation {
    condition = alltrue([
      for o in var.assignments.overrides : (
        alltrue([
          can(o.selectors) ? (
            alltrue([
              for s in o.selectors : (
                !(can(s.in) && can(s.not_in))
              )
            ])
          ) : true
        ])
      )
    ])
    error_message = "The 'in' and 'not_in' fields cannot be used together in override selectors."
  }
}
