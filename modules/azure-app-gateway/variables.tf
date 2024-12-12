variable "location" {
  description = "The location/region where the Application Gateway should be created."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Application Gateway."
  type        = string
}

variable "application_gateway" {
  description = "The Application Gateway object."
    type        = any
}

variable "public_ip" {
  description = "The Azure Public IP object."
  type        = any
}

variable "user_assigned_identity" {
  description = "The name of the User Assigned Identity."
  type        = string
}

variable "subnet" {
  description = "The subnet object."
  type        = any
}

variable "web_application_firewall_policy" {
  description = "Configuration for the web application firewall policy"
  type = object({
    name = string
    policy_settings = optional(object({
      enabled                     = optional(bool)
      mode                        = optional(string)
      request_body_check          = optional(bool)
      file_upload_limit_in_mb     = optional(number)
      max_request_body_size_in_kb = optional(number)
    }))
    managed_rules = list(object({
      managed_rule_set = object({
        type                = optional(string)
        version             = string
        rule_group_override = optional(list(object({
          rule_group_name = string
          rule = optional(list(object({
            id      = number
            enabled = optional(bool)
            action  = optional(string)
          })))
        })))
      })
    }))
  })
}
