## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples/basic) - Simple WAF with IP sets (whitelist/blacklist), CAPTCHA/Challenge config, and one AWS managed rule
- [Intermediate](https://github.com/prefapp/tfm/tree/main/modules/aws-waf/_examples/intermediate) - Multiple custom rules (byte_match, regex_match, ip_set_reference, regex_pattern_set_reference), managed rules, and CloudWatch logging with filters
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
