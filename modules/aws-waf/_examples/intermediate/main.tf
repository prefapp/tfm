provider "aws" {
  region = "eu-west-1"
}

module "waf" {
  source = "../../"

  name           = "webapp-waf"
  description    = "WAF for web application with custom rules and managed rules"
  scope          = "REGIONAL"
  default_action = "allow"

  ip_sets = {
    "trusted-partners" = {
      description        = "Trusted partner IP addresses"
      ip_address_version = "IPV4"
      addresses          = ["198.51.100.10/32", "203.0.113.25/32"]
    }
    "blocked-ips" = {
      description        = "Manually blocked IP addresses"
      ip_address_version = "IPV4"
      addresses          = ["192.0.2.100/32"]
    }
  }

  regex_pattern_sets = {
    "static-assets" = {
      description = "Pattern to match static asset paths"
      patterns    = ["^\\/static\\/assets\\/.*", "^\\/public\\/images\\/.*"]
    }
  }

  captcha_config = {
    immunity_time_property = {
      immunity_time = 300
    }
  }

  challenge_config = {
    immunity_time_property = {
      immunity_time = 300
    }
  }

  custom_rules = [
    {
      name     = "block-banned-ips"
      priority = 1
      action   = "block"
      statement = {
        ip_set_reference = {
          ip_set_key = "blocked-ips"
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "BlockBannedIPs"
      }
    },
    {
      name     = "allow-json-api"
      priority = 2
      action   = "allow"
      statement = {
        regex_match = {
          regex_string = "(?:\\.json$)"
          field_to_match = {
            json_body = {
              match_pattern = {
                all = {}
              }
              match_scope       = "VALUE"
              oversize_handling = "MATCH"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowJsonAPI"
      }
    },
    {
      name     = "allow-file-uploads"
      priority = 3
      action   = "allow"
      statement = {
        byte_match = {
          positional_constraint = "ENDS_WITH"
          search_string         = "/api/uploads/"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowFileUploads"
      }
    },
    {
      name     = "allow-avatar-endpoint"
      priority = 4
      action   = "allow"
      statement = {
        byte_match = {
          positional_constraint = "EXACTLY"
          search_string         = "/api/users/avatar/"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowAvatarEndpoint"
      }
    },
    {
      name     = "allow-bulk-operations"
      priority = 5
      action   = "allow"
      statement = {
        byte_match = {
          positional_constraint = "ENDS_WITH"
          search_string         = "/bulk-import/"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowBulkOperations"
      }
    },
    {
      name     = "allow-static-assets"
      priority = 8
      action   = "allow"
      statement = {
        regex_pattern_set_reference = {
          regex_set_key = "static-assets"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowStaticAssets"
      }
    },
    {
      name     = "allow-trusted-partners"
      priority = 14
      action   = "allow"
      statement = {
        ip_set_reference = {
          ip_set_key = "trusted-partners"
        }
      }
    }
  ]

  aws_managed_rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 6
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 7
    },
    {
      name     = "AWSManagedRulesAdminProtectionRuleSet"
      priority = 9
    },
    {
      name     = "AWSManagedRulesPHPRuleSet"
      priority = 10
    },
    {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 11
    },
    {
      name     = "AWSManagedRulesAnonymousIpList"
      priority = 12
    },
    {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 13
    }
  ]

  logging_configuration = {
    cloudwatch_log_group_retention_days = 30
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
            },
            {
              action_condition = { action = "COUNT" }
            },
            {
              action_condition = { action = "CAPTCHA" }
            },
            {
              action_condition = { action = "EXCLUDED_AS_COUNT" }
            },
            {
              action_condition = { action = "CHALLENGE" }
            }
          ]
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    Application = "webapp"
    ManagedBy   = "terraform"
  }
}

output "web_acl_arn" {
  description = "The ARN of the WebACL"
  value       = module.waf.web_acl_arn
}

output "web_acl_id" {
  description = "The ID of the WebACL"
  value       = module.waf.web_acl_id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logs"
  value       = module.waf.cloudwatch_log_group_name
}
