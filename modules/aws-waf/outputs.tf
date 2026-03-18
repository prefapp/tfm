output "web_acl_id" {
  description = "The ID of the WebACL"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "The ARN of the WebACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "The name of the WebACL"
  value       = aws_wafv2_web_acl.this.name
}

output "web_acl_capacity" {
  description = "The web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = aws_wafv2_web_acl.this.capacity
}

output "ip_set_arns" {
  description = "Map of IP set names to their ARNs"
  value = {
    for k, v in aws_wafv2_ip_set.this : k => v.arn
  }
}

output "ip_set_ids" {
  description = "Map of IP set names to their IDs"
  value = {
    for k, v in aws_wafv2_ip_set.this : k => v.id
  }
}

output "regex_pattern_set_arns" {
  description = "Map of regex pattern set names to their ARNs"
  value = {
    for k, v in aws_wafv2_regex_pattern_set.this : k => v.arn
  }
}

output "regex_pattern_set_ids" {
  description = "Map of regex pattern set names to their IDs"
  value = {
    for k, v in aws_wafv2_regex_pattern_set.this : k => v.id
  }
}

output "logging_configuration_id" {
  description = "The Amazon Resource Name (ARN) of the WAFv2 Web ACL logging configuration"
  value       = try(aws_wafv2_web_acl_logging_configuration.this[0].id, null)
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group created for WAF logging (if auto-created)"
  value       = try(aws_cloudwatch_log_group.waf[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group created for WAF logging (if auto-created)"
  value       = try(aws_cloudwatch_log_group.waf[0].arn, null)
}

output "association_ids" {
  description = "Map of associated resource ARNs to their association IDs"
  value = {
    for k, v in aws_wafv2_web_acl_association.this : k => v.id
  }
}
