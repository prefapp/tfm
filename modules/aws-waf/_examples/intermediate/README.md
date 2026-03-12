# Intermediate WAF Example

This example demonstrates a typical WAF configuration for a web application including:

- IP sets for trusted partners and blocked IPs
- Regex pattern sets for static assets
- Multiple custom rules with different statement types:
  - IP set reference (block/allow)
  - Regex match (inline regex)
  - Byte match (URI path matching)
  - Regex pattern set reference
- AWS Managed Rules (Common, Known Bad Inputs, Admin Protection, PHP, IP Reputation, Anonymous IP, SQLi)
- CloudWatch logging with automatic log group creation
- Log filtering to keep only BLOCK, COUNT, CAPTCHA, EXCLUDED_AS_COUNT, and CHALLENGE actions

## Features Demonstrated

| Feature | Description |
|---------|-------------|
| `ip_set_reference` | Block banned IPs and allow trusted partners |
| `regex_match` | Match JSON API requests directly with regex |
| `byte_match` | Match specific URI paths (ENDS_WITH, EXACTLY) |
| `regex_pattern_set_reference` | Match static assets using a pattern set |
| `aws_managed_rules` | Multiple AWS managed rule groups |
| `logging_configuration` | Auto-created CloudWatch Log Group with filtering |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `web_acl_arn` - The ARN to use for associating with ALB, API Gateway, etc.
- `web_acl_id` - The WebACL ID
- `cloudwatch_log_group_name` - The auto-created CloudWatch Log Group name

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
