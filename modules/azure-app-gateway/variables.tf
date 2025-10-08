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
      request_body_enforcement    = optional(string)
    }))
    custom_rules = optional(list(object({
      enabled               = optional(bool, true)
      name                  = string
      priority              = number
      rule_type             = string
      action                = string
      rate_limit_duration   = optional(string)
      rate_limit_threshold  = optional(number)
      group_rate_limit_by   = optional(string)
      match_conditions      = list(object({
        operator           = string
        negation_condition = optional(bool, false)
        match_values       = optional(list(string))
        transforms         = optional(list(string))
        match_variables    = list(object({
          variable_name = string
          selector      = optional(string)
        }))
      }))
    })), [])
    managed_rule_set = list(object({
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
    }))
  })
}

variable "application_gateway" {
  description = "Application Gateway configuration"
  type = object({
    ssl_policy = object({
      policy_type          = string
      policy_name          = optional(string)
      cipher_suites        = optional(list(string))
      min_protocol_version = optional(string)
    })
  })
  default = {
    ssl_policy = {
      policy_type = "Predefined"
      policy_name = "AppGwSslPolicy20220101"
    }
  }
}
