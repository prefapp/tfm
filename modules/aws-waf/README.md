<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_ip_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_regex_pattern_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_association_resource_arns"></a> [association\_resource\_arns](#input\_association\_resource\_arns) | List of resource ARNs to associate with the WebACL. <br/>Supports ALB, API Gateway, AppSync, Cognito User Pool, App Runner, and Verified Access Instance ARNs.<br/>Note: For CLOUDFRONT scope, associations are managed through CloudFront distribution configuration, not this variable. | `list(string)` | `[]` | no |
| <a name="input_aws_managed_rules"></a> [aws\_managed\_rules](#input\_aws\_managed\_rules) | List of AWS managed rule groups to include in the WebACL.<br/><br/>Note: To exclude a rule from the managed rule group, use rule\_action\_overrides with "count" action.<br/>The excluded\_rules parameter was deprecated in AWS Provider v5.x.<br/><br/>Example:<br/>[<br/>  {<br/>    name            = "AWSManagedRulesCommonRuleSet"<br/>    priority        = 10<br/>    override\_action = "none"<br/>    rule\_action\_overrides = {<br/>      "SizeRestrictions\_BODY" = "count"  # Effectively excludes this rule<br/>      "GenericRFI\_BODY"       = "count"  # Effectively excludes this rule<br/>    }<br/>  },<br/>  {<br/>    name            = "AWSManagedRulesKnownBadInputsRuleSet"<br/>    priority        = 20<br/>    override\_action = "none"<br/>  }<br/>] | <pre>list(object({<br/>    name                  = string<br/>    vendor_name           = optional(string, "AWS")<br/>    priority              = number<br/>    override_action       = optional(string, "none")<br/>    rule_action_overrides = optional(map(string), {})<br/>    version               = optional(string, null)<br/>    scope_down_statement  = optional(any, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_captcha_config"></a> [captcha\_config](#input\_captcha\_config) | CAPTCHA configuration for the WebACL.<br/>Example:<br/>{<br/>  immunity\_time\_property = {<br/>    immunity\_time = 300<br/>  }<br/>} | <pre>object({<br/>    immunity_time_property = optional(object({<br/>      immunity_time = number<br/>    }), null)<br/>  })</pre> | `null` | no |
| <a name="input_challenge_config"></a> [challenge\_config](#input\_challenge\_config) | Challenge configuration for the WebACL.<br/>Example:<br/>{<br/>  immunity\_time\_property = {<br/>    immunity\_time = 300<br/>  }<br/>} | <pre>object({<br/>    immunity_time_property = optional(object({<br/>      immunity_time = number<br/>    }), null)<br/>  })</pre> | `null` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Whether CloudWatch metrics are enabled for the WebACL | `bool` | `true` | no |
| <a name="input_custom_response_bodies"></a> [custom\_response\_bodies](#input\_custom\_response\_bodies) | Map of custom response bodies for the WebACL. Each key is the response body key to reference in rules.<br/>Example:<br/>{<br/>  "blocked" = {<br/>    content      = "<html><body><h1>Access Denied</h1></body></html>"<br/>    content\_type = "TEXT\_HTML"<br/>  }<br/>} | <pre>map(object({<br/>    content      = string<br/>    content_type = string # TEXT_PLAIN, TEXT_HTML, APPLICATION_JSON<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_rules"></a> [custom\_rules](#input\_custom\_rules) | List of custom rules to include in the WebACL. Supports various statement types.<br/><br/>Supported statement types:<br/>- ip\_set\_reference: Reference an IP set (use ip\_set\_key for module-created sets or ip\_set\_arn for external)<br/>- geo\_match: Match requests by country codes<br/>- rate\_based: Rate limiting rules<br/>- regex\_pattern\_set\_reference: Match against regex patterns<br/>- byte\_match: Match specific byte sequences<br/>- size\_constraint: Match request size<br/>- label\_match: Match labels from other rules<br/>- not/and/or: Compound statements<br/><br/>Example:<br/>[<br/>  {<br/>    name     = "block-bad-ips"<br/>    priority = 1<br/>    action   = "block"<br/>    statement = {<br/>      ip\_set\_reference = {<br/>        ip\_set\_key = "blocked-ips"<br/>      }<br/>    }<br/>  },<br/>  {<br/>    name     = "rate-limit"<br/>    priority = 5<br/>    action   = "block"<br/>    statement = {<br/>      rate\_based = {<br/>        limit              = 2000<br/>        aggregate\_key\_type = "IP"<br/>      }<br/>    }<br/>  }<br/>] | `any` | `[]` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | Default action for the WebACL. Valid values are 'allow' or 'block' | `string` | `"allow"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the WebACL | `string` | `""` | no |
| <a name="input_ip_sets"></a> [ip\_sets](#input\_ip\_sets) | Map of IP sets to create. Each key is the IP set name.<br/>Example:<br/>{<br/>  "allowed-ips" = {<br/>    description        = "Allowed IP addresses"<br/>    ip\_address\_version = "IPV4"<br/>    addresses          = ["10.0.0.0/8", "192.168.1.0/24"]<br/>  }<br/>  "blocked-ips-v6" = {<br/>    description        = "Blocked IPv6 addresses"<br/>    ip\_address\_version = "IPV6"<br/>    addresses          = ["2001:db8::/32"]<br/>  }<br/>} | <pre>map(object({<br/>    description        = optional(string, "")<br/>    ip_address_version = optional(string, "IPV4")<br/>    addresses          = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_logging_configuration"></a> [logging\_configuration](#input\_logging\_configuration) | Logging configuration for the WebACL.<br/>If log\_destination\_arns is not provided, a CloudWatch Log Group will be created automatically.<br/><br/>Example with custom destination:<br/>{<br/>  log\_destination\_arns = ["arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-example"]<br/>  redacted\_fields = [<br/>    {<br/>      single\_header = { name = "authorization" }<br/>    }<br/>  ]<br/>  logging\_filter = {<br/>    default\_behavior = "DROP"<br/>    filters = [<br/>      {<br/>        behavior    = "KEEP"<br/>        requirement = "MEETS\_ANY"<br/>        conditions = [<br/>          {<br/>            action\_condition = { action = "BLOCK" }<br/>          }<br/>        ]<br/>      }<br/>    ]<br/>  }<br/>}<br/><br/>Example with auto-created CloudWatch Log Group:<br/>{<br/>  cloudwatch\_log\_group\_retention\_days = 30<br/>} | <pre>object({<br/>    log_destination_arns                = optional(list(string), [])<br/>    cloudwatch_log_group_retention_days = optional(number, 30)<br/>    redacted_fields = optional(list(object({<br/>      method        = optional(object({}), null)<br/>      query_string  = optional(object({}), null)<br/>      single_header = optional(object({ name = string }), null)<br/>      uri_path      = optional(object({}), null)<br/>    })), [])<br/>    logging_filter = optional(object({<br/>      default_behavior = string<br/>      filters = list(object({<br/>        behavior    = string<br/>        requirement = string<br/>        conditions = list(object({<br/>          action_condition = optional(object({<br/>            action = string<br/>          }), null)<br/>          label_name_condition = optional(object({<br/>            label_name = string<br/>          }), null)<br/>        }))<br/>      }))<br/>    }), null)<br/>  })</pre> | `null` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | CloudWatch metric name for the WebACL. If not specified, the name will be used | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the WebACL and related resources | `string` | n/a | yes |
| <a name="input_regex_pattern_sets"></a> [regex\_pattern\_sets](#input\_regex\_pattern\_sets) | Map of regex pattern sets to create. Each key is the pattern set name.<br/>Example:<br/>{<br/>  "bad-patterns" = {<br/>    description = "Patterns to block"<br/>    patterns    = [".*badbot.*", ".*malware.*"]<br/>  }<br/>} | <pre>map(object({<br/>    description = optional(string, "")<br/>    patterns    = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_rule_group_references"></a> [rule\_group\_references](#input\_rule\_group\_references) | List of rule group ARNs to reference in the WebACL.<br/><br/>Note: To exclude a rule from the rule group, use rule\_action\_overrides with "count" action.<br/>The excluded\_rules parameter was deprecated in AWS Provider v5.x.<br/><br/>Example:<br/>[<br/>  {<br/>    arn             = "arn:aws:wafv2:us-east-1:123456789012:regional/rulegroup/my-rule-group/12345678"<br/>    priority        = 50<br/>    override\_action = "none"<br/>    rule\_action\_overrides = {<br/>      "some-rule-name" = "count"  # Effectively excludes this rule<br/>    }<br/>  }<br/>] | <pre>list(object({<br/>    arn                   = string<br/>    priority              = number<br/>    override_action       = optional(string, "none")<br/>    rule_action_overrides = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | Whether AWS WAF should store a sampling of the web requests that match the rules | `bool` | `true` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Scope of the WebACL. Valid values are CLOUDFRONT or REGIONAL. For CLOUDFRONT, the provider region must be us-east-1 | `string` | `"REGIONAL"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_token_domains"></a> [token\_domains](#input\_token\_domains) | List of domains that AWS WAF should accept in a web request token | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_association_ids"></a> [association\_ids](#output\_association\_ids) | Map of associated resource ARNs to their association IDs |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch Log Group created for WAF logging (if auto-created) |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch Log Group created for WAF logging (if auto-created) |
| <a name="output_ip_set_arns"></a> [ip\_set\_arns](#output\_ip\_set\_arns) | Map of IP set names to their ARNs |
| <a name="output_ip_set_ids"></a> [ip\_set\_ids](#output\_ip\_set\_ids) | Map of IP set names to their IDs |
| <a name="output_logging_configuration_id"></a> [logging\_configuration\_id](#output\_logging\_configuration\_id) | The Amazon Resource Name (ARN) of the WAFv2 Web ACL logging configuration |
| <a name="output_regex_pattern_set_arns"></a> [regex\_pattern\_set\_arns](#output\_regex\_pattern\_set\_arns) | Map of regex pattern set names to their ARNs |
| <a name="output_regex_pattern_set_ids"></a> [regex\_pattern\_set\_ids](#output\_regex\_pattern\_set\_ids) | Map of regex pattern set names to their IDs |
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | The ARN of the WebACL |
| <a name="output_web_acl_capacity"></a> [web\_acl\_capacity](#output\_web\_acl\_capacity) | The web ACL capacity units (WCUs) currently being used by this web ACL |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The ID of the WebACL |
| <a name="output_web_acl_name"></a> [web\_acl\_name](#output\_web\_acl\_name) | The name of the WebACL |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples/basic) - Simple WAF with IP sets (whitelist/blacklist), CAPTCHA/Challenge config, and one AWS managed rule
- [Intermediate](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples/intermediate) - Multiple custom rules (byte\_match, regex\_match, ip\_set\_reference, regex\_pattern\_set\_reference), managed rules, and CloudWatch logging with filters
- [Complete](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples/complete) - Full features including IP sets, regex patterns, custom response bodies, rate limiting, geo-blocking, and size constraints

## AWS Managed Rules Reference

The following AWS Managed Rule Groups are available (free tier unless noted):

| Rule Group Name | Description |
|----------------|-------------|
| `AWSManagedRulesCommonRuleSet` | Contains rules that are generally applicable to web applications |
| `AWSManagedRulesKnownBadInputsRuleSet` | Blocks request patterns known to be invalid |
| `AWSManagedRulesSQLiRuleSet` | Blocks SQL injection attacks |
| `AWSManagedRulesLinuxRuleSet` | Blocks Linux-specific LFI attacks |
| `AWSManagedRulesUnixRuleSet` | Blocks POSIX/Unix-specific LFI attacks |
| `AWSManagedRulesWindowsRuleSet` | Blocks Windows-specific attacks |
| `AWSManagedRulesPHPRuleSet` | Blocks PHP-specific attacks |
| `AWSManagedRulesWordPressRuleSet` | Blocks WordPress-specific attacks |
| `AWSManagedRulesAmazonIpReputationList` | Blocks IPs with poor reputation |
| `AWSManagedRulesAnonymousIpList` | Blocks IPs from anonymous proxies |
| `AWSManagedRulesBotControlRuleSet` | Bot management (paid) |
| `AWSManagedRulesATPRuleSet` | Account takeover prevention (paid) |
| `AWSManagedRulesACFPRuleSet` | Account creation fraud prevention (paid) |
| `AWSManagedRulesAntiDDoSRuleSet` | Layer 7 DDoS protection (paid) |

### Managed Rules Action Configuration

When using AWS Managed Rules, you have two levels of control:

#### 1. `override_action` (Rule Group Level)

Controls the behavior of the entire rule group:

| Value | Description |
|-------|-------------|
| `none` | Use actions defined in the rule group (normal behavior - blocks, counts, etc.) |
| `count` | Override ALL rules to count mode (useful for testing/monitoring before enforcement) |

#### 2. `rule_action_overrides` (Individual Rule Level)

Customize the action for specific rules within the group:

| Action | Description |
|--------|-------------|
| `allow` | Allow the request |
| `block` | Block the request |
| `count` | Count but don't block (monitoring mode / effectively excludes the rule) |
| `captcha` | Present a CAPTCHA challenge |
| `challenge` | Present a silent challenge |

> **Note:** The `excluded_rules` parameter was deprecated in AWS Provider v5.x and removed in v6.x.
> To exclude a rule, use `rule_action_overrides` with `"count"` action instead.

**Example:**
```hcl
aws_managed_rules = [
  {
    name            = "AWSManagedRulesCommonRuleSet"
    priority        = 10
    override_action = "none"  # Use rule group's default actions
    rule_action_overrides = {
      "SizeRestrictions_BODY" = "count"    # Effectively excludes this rule (count only)
      "GenericRFI_BODY"       = "count"    # Effectively excludes this rule (count only)
      "NoUserAgent_HEADER"    = "captcha"  # Challenge missing user-agent
    }
  }
]
```

## Custom Rule Statement Types

The module supports the following statement types for custom rules:

| Statement Type | Description |
|---------------|-------------|
| `ip_set_reference` | Match against an IP set (use `ip_set_key` for module-created sets) |
| `geo_match` | Match requests by country codes |
| `rate_based` | Rate limiting with configurable limits and aggregation |
| `regex_pattern_set_reference` | Match against a regex pattern set (use `regex_set_key` for module-created sets) |
| `regex_match` | Match against a regex string directly (no pattern set needed) |
| `byte_match` | Match specific byte sequences in request components |
| `size_constraint` | Match based on request component size |
| `label_match` | Match labels from other rules |
| `not` | Negate a statement |
| `and` | Combine multiple statements with AND logic |
| `or` | Combine multiple statements with OR logic |

## Resources

- **AWS WAFv2 Documentation**: [https://docs.aws.amazon.com/waf/latest/developerguide/](https://docs.aws.amazon.com/waf/latest/developerguide/)
- **AWS Managed Rules Documentation**: [https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups.html](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups.html)
- **Terraform AWS Provider - WAFv2**: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl)
- **AWS WAF Pricing**: [https://aws.amazon.com/waf/pricing/](https://aws.amazon.com/waf/pricing/)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->
