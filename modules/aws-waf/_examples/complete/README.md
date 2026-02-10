# Complete WAF Example

This example demonstrates a comprehensive AWS WAFv2 configuration including:

- IP sets (allowed and blocked IPs)
- Regex pattern sets for user-agent filtering
- Custom response bodies (JSON and HTML)
- AWS Managed Rules (Common, Known Bad Inputs, SQLi, IP Reputation)
- Custom rules:
  - Allow trusted IPs
  - Block malicious IPs with custom response
  - Rate limiting with custom 429 response
  - Geo-blocking
  - Bad user-agent blocking
  - Request size limiting
  - Admin path protection
- CAPTCHA and Challenge configurations

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

After applying, you'll get:

- `web_acl_arn` - The ARN to use for associating with ALB, API Gateway, etc.
- `web_acl_id` - The WebACL ID
- `ip_set_arns` - Map of IP set ARNs for reference in other modules
- `regex_pattern_set_arns` - Map of regex pattern set ARNs

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

## Notes

- For CloudFront distributions, use `scope = "CLOUDFRONT"` and deploy in `us-east-1` region
- The WebACL ARN can be used directly in CloudFront distribution's `web_acl_id` attribute
