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
