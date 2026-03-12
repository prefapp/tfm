# **AWS WAF Terraform Module**

## Overview

This Terraform module provides a comprehensive solution for creating and managing AWS WAFv2 Web Application Firewalls. It enables organizations to protect their web applications from common web exploits and bots that could affect application availability, compromise security, or consume excessive resources.

The module supports both REGIONAL scope (for ALB, API Gateway, AppSync, Cognito User Pool, App Runner, and Verified Access instances) and CLOUDFRONT scope (for CloudFront distributions). It provides a flexible and declarative way to define security rules, including AWS Managed Rule Groups, custom rules with various match conditions, IP-based filtering, geo-blocking, and rate limiting.

With this module, teams can standardize WAF configurations across multiple environments and accounts, ensuring consistent security policies while maintaining the flexibility to customize rules based on specific application requirements. The module is designed for production use cases where security, reproducibility, and maintainability are critical concerns.

## Key Features

- **WebACL Management**: Create and configure WAFv2 WebACLs with customizable default actions (allow/block) for both REGIONAL and CLOUDFRONT scopes.
- **AWS Managed Rules**: Easy integration with AWS Managed Rule Groups including CommonRuleSet, KnownBadInputsRuleSet, SQLiRuleSet, and IP Reputation lists with support for rule action overrides.
- **IP Sets**: Define IPv4 and IPv6 IP sets for allowlisting trusted sources or blocklisting malicious IPs, with automatic ARN resolution in rules.
- **Regex Pattern Sets**: Create reusable regex pattern sets for matching against request components like headers, URI paths, or query strings.
- **Custom Rules**: Support for multiple statement types including geo match, rate-based limiting, byte match, size constraints, and compound statements (AND/OR/NOT).
- **Custom Response Bodies**: Define custom HTTP responses (JSON, HTML, or plain text) with custom headers for blocked requests.
- **Resource Association**: Automatic association with ALB, API Gateway, AppSync, and other supported AWS resources.
- **Logging Configuration**: Full logging support with Firehose/S3/CloudWatch destinations, field redaction, and log filtering capabilities.
- **CAPTCHA & Challenge**: Built-in support for CAPTCHA and Challenge actions with configurable immunity times.

## Basic Usage

### Minimal Configuration with AWS Managed Rules

```hcl
module "waf" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-waf"

  name           = "my-application-waf"
  description    = "WAF for my web application"
  scope          = "REGIONAL"
  default_action = "allow"

  aws_managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 20
      override_action = "none"
    }
  ]

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Configuration with IP Sets and Custom Rules

```hcl
module "waf" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-waf"

  name           = "api-gateway-waf"
  description    = "WAF protecting API Gateway endpoints"
  scope          = "REGIONAL"
  default_action = "allow"

  ip_sets = {
    "trusted-partners" = {
      description        = "Partner IP addresses"
      ip_address_version = "IPV4"
      addresses          = ["203.0.113.0/24", "198.51.100.0/24"]
    }
    "blocked-ips" = {
      description        = "Known malicious IPs"
      ip_address_version = "IPV4"
      addresses          = ["192.0.2.0/24"]
    }
  }

  custom_response_bodies = {
    "rate-limited" = {
      content      = "{\"error\": \"rate_limit_exceeded\", \"message\": \"Too many requests\"}"
      content_type = "APPLICATION_JSON"
    }
  }

  aws_managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
    }
  ]

  custom_rules = [
    {
      name     = "allow-trusted-partners"
      priority = 1
      action   = "allow"
      statement = {
        ip_set_reference = {
          ip_set_key = "trusted-partners"
        }
      }
    },
    {
      name     = "block-malicious-ips"
      priority = 2
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
      action_block_custom_response = {
        response_code            = 429
        custom_response_body_key = "rate-limited"
      }
      statement = {
        rate_based = {
          limit              = 2000
          aggregate_key_type = "IP"
        }
      }
    }
  ]

  association_resource_arns = [
    "arn:aws:elasticloadbalancing:eu-west-1:123456789012:loadbalancer/app/my-alb/1234567890123456"
  ]

  tags = {
    Environment = "production"
  }
}
```

### AWS Managed Rules with Individual Rule Overrides

```hcl
module "waf" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-waf"

  name           = "managed-rules-waf"
  description    = "WAF with customized managed rules"
  scope          = "REGIONAL"
  default_action = "allow"

  aws_managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      # override_action: Controls the entire rule group
      #   - "none": Use actions defined in the rule group (normal behavior)
      #   - "count": Override ALL rules to count mode (testing/monitoring)
      override_action = "none"
      
      # rule_action_overrides: Customize individual rules within the group
      # Available actions: "allow", "block", "count", "captcha", "challenge"
      rule_action_overrides = {
        "SizeRestrictions_BODY"  = "count"     # Monitor instead of block
        "GenericRFI_BODY"        = "count"     # Monitor instead of block
        "CrossSiteScripting_BODY" = "block"   # Ensure this blocks
        "NoUserAgent_HEADER"     = "captcha"  # Challenge suspicious requests
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
      # Set to "count" to monitor SQL injection attempts without blocking
      # Useful for initial deployment and tuning
      override_action = "count"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### CloudFront Distribution WAF

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "waf_cloudfront" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-waf"
  providers = {
    aws = aws.us_east_1
  }

  name           = "cloudfront-waf"
  description    = "WAF for CloudFront distribution"
  scope          = "CLOUDFRONT"
  default_action = "allow"

  aws_managed_rules = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = 20
      override_action = "none"
    }
  ]

  custom_rules = [
    {
      name     = "geo-block"
      priority = 5
      action   = "block"
      statement = {
        geo_match = {
          country_codes = ["KP", "IR", "SY"]
        }
      }
    }
  ]

  tags = {
    Environment = "production"
  }
}

resource "aws_cloudfront_distribution" "example" {
  # ... other configuration ...
  web_acl_id = module.waf_cloudfront.web_acl_arn
}
```
