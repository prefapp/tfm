provider "aws" {
  region = "eu-west-1"
}

module "waf" {
  source = "../../"

  name           = "basic-waf"
  description    = "Basic WAF with IP rules and bot protection"
  scope          = "REGIONAL"
  default_action = "allow"

  ip_sets = {
    "allowed-ips" = {
      description        = "Allowed IP addresses (whitelist)"
      ip_address_version = "IPV4"
      addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    }
    "blocked-ips" = {
      description        = "Blocked IP addresses (blacklist)"
      ip_address_version = "IPV4"
      addresses          = []
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
      name     = "block-blacklisted-ips"
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
        metric_name                = "BlockBlacklistedIPs"
      }
    },
    {
      name     = "allow-whitelisted-ips"
      priority = 2
      action   = "allow"
      statement = {
        ip_set_reference = {
          ip_set_key = "allowed-ips"
        }
      }
      visibility_config = {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowWhitelistedIPs"
      }
    }
  ]

  aws_managed_rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10
    }
  ]

  tags = {
    Environment = "development"
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
