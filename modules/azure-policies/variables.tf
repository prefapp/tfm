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
  validation {
    condition = alltrue([
      for policy in var.policies : contains(["BuiltIn", "Custom", "NotSpecified", "Static"], policy.policy_type)
    ])
    error_message = "Invalid value for policy_type."
  }
  validation {
    condition = alltrue([
      for policy in var.policies : contains(["All", "Indexed", "Microsoft.ContainerService.Data", "Microsoft.CustomerLockbox.Data", "Microsoft.DataCatalog.Data", "Microsoft.KeyVault.Data", "Microsoft.Kubernetes.Data", "Microsoft.MachineLearningServices.Data", "Microsoft.Network.Data", "Microsoft.Synapse.Data"], policy.mode)
    ])
    error_message = "Invalid value for mode."
  }
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
  validation {
    condition = alltrue([
      for assignment in var.assignments : length(assignment.name) <= 64
    ])
    error_message = "Invalid value for name length. It cannot exceed 64 characters."
  }
  validation {
    condition = alltrue([
      for assignment in var.assignments : contains(["SystemAssigned", "UserAssigned"], assignment.identity.type)
    ])
    error_message = "Invalid value for identity type. Possible values are SystemAssigned and UserAssigned."
  }
  validation {
    condition = alltrue([
      for assignment in var.assignments : can(assignment.identity) ? can(assignment.location) : true
    ])
    error_message = "The location field must also be specified when identity is specified."
  }
}
