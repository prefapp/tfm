variable "policies" {
  description = "Policy definitions to create; empty list creates no resources."
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
