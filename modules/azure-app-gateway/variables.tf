variable "tags_from_rg" {
  description = "Use resource group tags as base for module tags"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

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
  description = "Structured Application Gateway configuration (SKU, autoscale, identity, listeners, `blocks_defaults`, `blocks`, SSL certificates, etc.). See `_examples/comprehensive/values.reference.yaml` for a full shape."
  type        = any
}

variable "public_ip" {
  description = "Public IP for the Application Gateway frontend (`name`, `sku`, `allocation_method`, etc.)."
  type        = any
}

variable "user_assigned_identity" {
  description = "The name of the User Assigned Identity."
  type        = string
}

variable "subnet" {
  description = "Subnet where the gateway is deployed (`name`, `virtual_network_name` within `resource_group_name`)."
  type        = any
}

variable "ssl_profiles" {
  description = "List of SSL profiles for Application Gateway. CA files under `ca_certs_origin.github_directory` are listed via the GitHub Contents API in `data.tf`; `ca_certs_origin.github_branch` is accepted for forward compatibility but is not passed to that API today (content is read from the repository default branch)."
  type = list(object({
    name                                     = string
    trusted_client_certificate_names         = optional(list(string))
    verify_client_cert_issuer_dn             = optional(bool, false)
    verify_client_certificate_revocation     = optional(string)
    ssl_policy = optional(object({
      disabled_protocols                     = optional(list(string))
      min_protocol_version                   = optional(string)
      policy_name                            = optional(string)
      cipher_suites                          = optional(list(string))
    }))
    ca_certs_origin = object({
      github_owner       = string
      github_repository  = string
      github_branch      = string
      github_directory   = string
    })
  }))
  default = []
}

variable "rewrite_rule_sets" {
  description = "List of Rewrite Rule Sets for Application Gateway"
  type = list(object({
    name = string
    rewrite_rules = list(object({
      name          = string
      rule_sequence = number
      conditions = optional(list(object({
        variable    = string
        pattern     = string
        ignore_case = optional(bool, false)
        negate      = optional(bool, false)
      })), [])
      request_header_configurations = optional(list(object({
        header_name  = string
        header_value = string
      })), [])
      response_header_configurations = optional(list(object({
        header_name  = string
        header_value = string
      })), [])
      url_rewrite = optional(object({
        source_path = optional(string)
        query_string = optional(string)
        components = optional(string)
        reroute = optional(bool)
      }))
    }))
  }))
  default = []
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

variable "ssl_policy" {
  description = "Gateway-level SSL policy (`policy_type`, optional `policy_name`, `cipher_suites`, `min_protocol_version`)."
  type = object({
    policy_type          = string
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }
}
