# Basic WAF Example

This example demonstrates a simple AWS WAFv2 configuration suitable for getting started with WAF protection, including:

- IP sets for whitelisting and blacklisting
- Simple IP-based custom rules (allow/block)
- One AWS Managed Rule (CommonRuleSet)
- CAPTCHA and Challenge configuration

## Features Demonstrated

| Feature | Description |
|---------|-------------|
| `ip_sets` | Create IPv4 sets for allowed and blocked IPs |
| `ip_set_reference` | Reference IP sets in custom rules |
| `aws_managed_rules` | Basic CommonRuleSet for common attack protection |
| `captcha_config` | CAPTCHA immunity time configuration |
| `challenge_config` | Challenge immunity time configuration |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `web_acl_arn` - The ARN to use for associating with ALB, API Gateway, etc.
- `web_acl_id` - The WebACL ID
- `ip_set_arns` - Map of IP set ARNs (allowed-ips, blocked-ips)

## Associating with ALB

To associate this WAF with an Application Load Balancer, add the `association_resource_arns` variable:

```hcl
module "waf" {
  source = "../../"
  # ... other configuration ...

  association_resource_arns = [
    aws_lb.my_alb.arn
  ]
}
```

## Next Steps

For more advanced configurations, see:
- [Intermediate Example](../intermediate/) - Multiple custom rules, regex patterns, logging with filters
- [Complete Example](../complete/) - Full features including custom response bodies, geo-blocking, rate limiting
