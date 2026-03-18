################################################################################
# General Configuration
################################################################################

variable "name" {
  description = "Name of the WebACL and related resources"
  type        = string
}

variable "description" {
  description = "Description of the WebACL"
  type        = string
  default     = ""
}

variable "scope" {
  description = "Scope of the WebACL. Valid values are CLOUDFRONT or REGIONAL. For CLOUDFRONT, the provider region must be us-east-1"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "Scope must be either CLOUDFRONT or REGIONAL."
  }
}

variable "default_action" {
  description = "Default action for the WebACL. Valid values are 'allow' or 'block'"
  type        = string
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either 'allow' or 'block'."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Visibility Configuration
################################################################################

variable "cloudwatch_metrics_enabled" {
  description = "Whether CloudWatch metrics are enabled for the WebACL"
  type        = bool
  default     = true
}

variable "sampled_requests_enabled" {
  description = "Whether AWS WAF should store a sampling of the web requests that match the rules"
  type        = bool
  default     = true
}

variable "metric_name" {
  description = "CloudWatch metric name for the WebACL. If not specified, the name will be used"
  type        = string
  default     = null
}

################################################################################
# Token Domains (for CAPTCHA/Challenge)
################################################################################

variable "token_domains" {
  description = "List of domains that AWS WAF should accept in a web request token"
  type        = list(string)
  default     = []
}

################################################################################
# Custom Response Bodies
################################################################################

variable "custom_response_bodies" {
  description = <<-EOT
    Map of custom response bodies for the WebACL. Each key is the response body key to reference in rules.
    Example:
    {
      "blocked" = {
        content      = "<html><body><h1>Access Denied</h1></body></html>"
        content_type = "TEXT_HTML"
      }
    }
  EOT
  type = map(object({
    content      = string
    content_type = string # TEXT_PLAIN, TEXT_HTML, APPLICATION_JSON
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.custom_response_bodies : contains(["TEXT_PLAIN", "TEXT_HTML", "APPLICATION_JSON"], v.content_type)
    ])
    error_message = "Content type must be one of: TEXT_PLAIN, TEXT_HTML, APPLICATION_JSON."
  }
}

################################################################################
# IP Sets
################################################################################

variable "ip_sets" {
  description = <<-EOT
    Map of IP sets to create. Each key is the IP set name.
    Example:
    {
      "allowed-ips" = {
        description        = "Allowed IP addresses"
        ip_address_version = "IPV4"
        addresses          = ["10.0.0.0/8", "192.168.1.0/24"]
      }
      "blocked-ips-v6" = {
        description        = "Blocked IPv6 addresses"
        ip_address_version = "IPV6"
        addresses          = ["2001:db8::/32"]
      }
    }
  EOT
  type = map(object({
    description        = optional(string, "")
    ip_address_version = optional(string, "IPV4")
    addresses          = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.ip_sets : contains(["IPV4", "IPV6"], v.ip_address_version)
    ])
    error_message = "IP address version must be either IPV4 or IPV6."
  }
}

################################################################################
# Regex Pattern Sets
################################################################################

variable "regex_pattern_sets" {
  description = <<-EOT
    Map of regex pattern sets to create. Each key is the pattern set name.
    Example:
    {
      "bad-patterns" = {
        description = "Patterns to block"
        patterns    = [".*badbot.*", ".*malware.*"]
      }
    }
  EOT
  type = map(object({
    description = optional(string, "")
    patterns    = list(string)
  }))
  default = {}
}

################################################################################
# AWS Managed Rules
################################################################################

variable "aws_managed_rules" {
  description = <<-EOT
    List of AWS managed rule groups to include in the WebACL.

    Note: To exclude a rule from the managed rule group, use rule_action_overrides with "count" action.
    The excluded_rules parameter was deprecated in AWS Provider v5.x.

    Example:
    [
      {
        name            = "AWSManagedRulesCommonRuleSet"
        priority        = 10
        override_action = "none"
        rule_action_overrides = {
          "SizeRestrictions_BODY" = "count"  # Effectively excludes this rule
          "GenericRFI_BODY"       = "count"  # Effectively excludes this rule
        }
      },
      {
        name            = "AWSManagedRulesKnownBadInputsRuleSet"
        priority        = 20
        override_action = "none"
      }
    ]
  EOT
  type = list(object({
    name                  = string
    vendor_name           = optional(string, "AWS")
    priority              = number
    override_action       = optional(string, "none")
    rule_action_overrides = optional(map(string), {})
    version               = optional(string, null)
    scope_down_statement  = optional(any, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.aws_managed_rules : contains(["none", "count"], rule.override_action)
    ])
    error_message = "Override action must be either 'none' or 'count'."
  }
}

################################################################################
# Custom Rules
################################################################################

variable "custom_rules" {
  description = <<-EOT
    List of custom rules to include in the WebACL. Supports various statement types.

    Supported statement types:
    - ip_set_reference: Reference an IP set (use ip_set_key for module-created sets or ip_set_arn for external)
    - geo_match: Match requests by country codes
    - rate_based: Rate limiting rules
    - regex_pattern_set_reference: Match against regex patterns
    - byte_match: Match specific byte sequences
    - size_constraint: Match request size
    - label_match: Match labels from other rules
    - not/and/or: Compound statements

    Example:
    [
      {
        name     = "block-bad-ips"
        priority = 1
        action   = "block"
        statement = {
          ip_set_reference = {
            ip_set_key = "blocked-ips"
          }
        }
      },
      {
        name     = "rate-limit"
        priority = 5
        action   = "block"
        statement = {
          rate_based = {
            limit              = 2000
            aggregate_key_type = "IP"
          }
        }
      }
    ]
  EOT
  type        = any
  default     = []
}

################################################################################
# Rule Groups
################################################################################

variable "rule_group_references" {
  description = <<-EOT
    List of rule group ARNs to reference in the WebACL.

    Note: To exclude a rule from the rule group, use rule_action_overrides with "count" action.
    The excluded_rules parameter was deprecated in AWS Provider v5.x.

    Example:
    [
      {
        arn             = "arn:aws:wafv2:us-east-1:123456789012:regional/rulegroup/my-rule-group/12345678"
        priority        = 50
        override_action = "none"
        rule_action_overrides = {
          "some-rule-name" = "count"  # Effectively excludes this rule
        }
      }
    ]
  EOT
  type = list(object({
    arn                   = string
    priority              = number
    override_action       = optional(string, "none")
    rule_action_overrides = optional(map(string), {})
  }))
  default = []
}

################################################################################
# Association Configuration
################################################################################

variable "association_resource_arns" {
  description = <<-EOT
    List of resource ARNs to associate with the WebACL.
    Supports ALB, API Gateway, AppSync, Cognito User Pool, App Runner, and Verified Access Instance ARNs.
    Note: For CLOUDFRONT scope, associations are managed through CloudFront distribution configuration, not this variable.
  EOT
  type        = list(string)
  default     = []
}

################################################################################
# Logging Configuration
################################################################################

variable "logging_configuration" {
  description = <<-EOT
    Logging configuration for the WebACL.
    If log_destination_arns is not provided, a CloudWatch Log Group will be created automatically.

    Example with custom destination:
    {
      log_destination_arns = ["arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-example"]
      redacted_fields = [
        {
          single_header = { name = "authorization" }
        }
      ]
      logging_filter = {
        default_behavior = "DROP"
        filters = [
          {
            behavior    = "KEEP"
            requirement = "MEETS_ANY"
            conditions = [
              {
                action_condition = { action = "BLOCK" }
              }
            ]
          }
        ]
      }
    }

    Example with auto-created CloudWatch Log Group:
    {
      cloudwatch_log_group_retention_days = 30
    }
  EOT
  type = object({
    log_destination_arns                = optional(list(string), [])
    cloudwatch_log_group_retention_days = optional(number, 30)
    redacted_fields = optional(list(object({
      method        = optional(object({}), null)
      query_string  = optional(object({}), null)
      single_header = optional(object({ name = string }), null)
      uri_path      = optional(object({}), null)
    })), [])
    logging_filter = optional(object({
      default_behavior = string
      filters = list(object({
        behavior    = string
        requirement = string
        conditions = list(object({
          action_condition = optional(object({
            action = string
          }), null)
          label_name_condition = optional(object({
            label_name = string
          }), null)
        }))
      }))
    }), null)
  })
  default = null
}

################################################################################
# Protection Settings (CAPTCHA/Challenge)
################################################################################

variable "captcha_config" {
  description = <<-EOT
    CAPTCHA configuration for the WebACL.
    Example:
    {
      immunity_time_property = {
        immunity_time = 300
      }
    }
  EOT
  type = object({
    immunity_time_property = optional(object({
      immunity_time = number
    }), null)
  })
  default = null
}

variable "challenge_config" {
  description = <<-EOT
    Challenge configuration for the WebACL.
    Example:
    {
      immunity_time_property = {
        immunity_time = 300
      }
    }
  EOT
  type = object({
    immunity_time_property = optional(object({
      immunity_time = number
    }), null)
  })
  default = null
}
