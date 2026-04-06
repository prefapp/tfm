provider "aws" {
  region = "eu-west-1"
}

module "waf" {
  source = "../../"

  name           = "example-web-acl"
  description    = "Example WAF configuration with all features"
  scope          = "REGIONAL"
  default_action = "allow"

  ip_sets = {
    "allowed-ips" = {
      description        = "Trusted IP addresses"
      ip_address_version = "IPV4"
      addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    }
    "blocked-ips" = {
      description        = "Known malicious IPs"
      ip_address_version = "IPV4"
      addresses          = ["203.0.113.0/24", "198.51.100.0/24"]
    }
  }

  regex_pattern_sets = {
    "bad-user-agents" = {
      description = "Known bad bot user agents"
      patterns    = [".*badbot.*", ".*scraper.*", ".*crawler.*", ".*spider.*"]
    }
    "sql-patterns" = {
      description = "Additional SQL injection patterns"
      patterns    = [".*union.*select.*", ".*drop.*table.*"]
    }
  }

  custom_response_bodies = {
    "blocked-json" = {
      content      = "{\"error\": \"Access Denied\", \"message\": \"Your request has been blocked by WAF\", \"code\": \"WAF_BLOCKED\"}"
      content_type = "APPLICATION_JSON"
    }
    "rate-limited-html" = {
      content      = "<html><head><title>Rate Limited</title></head><body><h1>429 Too Many Requests</h1><p>You have exceeded the allowed request rate. Please wait and try again.</p></body></html>"
      content_type = "TEXT_HTML"
    }
  }

  aws_managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
      rule_action_overrides = {
        "SizeRestrictions_BODY" = "count"
        "GenericRFI_BODY"       = "count"
      }
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 20
      override_action = "none"
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet"
      priority        = 30
      override_action = "none"
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = 40
      override_action = "none"
    }
  ]

  custom_rules = [
    {
      name     = "allow-trusted-ips"
      priority = 1
      action   = "allow"
      statement = {
        ip_set_reference = {
          ip_set_key = "allowed-ips"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowTrustedIPs"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "block-malicious-ips"
      priority = 2
      action   = "block"
      action_block_custom_response = {
        response_code            = 403
        custom_response_body_key = "blocked-json"
        response_headers = [
          {
            name  = "X-Blocked-By"
            value = "WAF-IP-Block"
          }
        ]
      }
      statement = {
        ip_set_reference = {
          ip_set_key = "blocked-ips"
        }
      }
    },
    {
      name     = "rate-limit-per-ip"
      priority = 5
      action   = "block"
      action_block_custom_response = {
        response_code            = 429
        custom_response_body_key = "rate-limited-html"
        response_headers = [
          {
            name  = "Retry-After"
            value = "300"
          }
        ]
      }
      statement = {
        rate_based = {
          limit                 = 2000
          aggregate_key_type    = "IP"
          evaluation_window_sec = 300
        }
      }
    },
    {
      name     = "block-high-risk-countries"
      priority = 15
      action   = "block"
      action_block_custom_response = {
        response_code            = 403
        custom_response_body_key = "blocked-json"
      }
      statement = {
        geo_match = {
          country_codes = ["KP", "IR", "SY"]
        }
      }
    },
    {
      name     = "block-bad-user-agents"
      priority = 20
      action   = "block"
      statement = {
        regex_pattern_set_reference = {
          regex_set_key = "bad-user-agents"
          field_to_match = {
            single_header = {
              name = "user-agent"
            }
          }
          text_transformation = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
        }
      }
    },
    {
      name     = "block-large-requests"
      priority = 25
      action   = "block"
      statement = {
        size_constraint = {
          comparison_operator = "GT"
          size                = 8192
          field_to_match = {
            body = {}
          }
          text_transformation = [
            {
              priority = 0
              type     = "NONE"
            }
          ]
        }
      }
    },
    {
      name     = "block-admin-from-non-trusted"
      priority = 30
      action   = "block"
      statement = {
        and = {
          statements = [
            {
              byte_match = {
                positional_constraint = "STARTS_WITH"
                search_string         = "/admin"
                field_to_match = {
                  uri_path = {}
                }
                text_transformation = [
                  {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                ]
              }
            },
            {
              not = {
                ip_set_reference = {
                  ip_set_key = "allowed-ips"
                }
              }
            }
          ]
        }
      }
    }
  ]

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

  tags = {
    Environment = "example"
    Project     = "waf-demo"
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

output "ip_set_arns" {
  description = "Map of IP set ARNs"
  value       = module.waf.ip_set_arns
}

output "regex_pattern_set_arns" {
  description = "Map of regex pattern set ARNs"
  value       = module.waf.regex_pattern_set_arns
}
