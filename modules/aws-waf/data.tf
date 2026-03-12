locals {
  metric_name = coalesce(var.metric_name, replace(var.name, "-", ""))

  ip_set_arns = {
    for k, v in aws_wafv2_ip_set.this : k => v.arn
  }

  regex_pattern_set_arns = {
    for k, v in aws_wafv2_regex_pattern_set.this : k => v.arn
  }

  create_cloudwatch_log_group = var.logging_configuration != null && length(var.logging_configuration.log_destination_arns) == 0
  log_destination_configs     = local.create_cloudwatch_log_group ? [aws_cloudwatch_log_group.waf[0].arn] : var.logging_configuration != null ? var.logging_configuration.log_destination_arns : []
}
