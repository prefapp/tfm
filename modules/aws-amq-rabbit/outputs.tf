output "broker_urls" {
  description = "Nested list of broker endpoints for the Amazon MQ Broker. Each element is a list of endpoints for a broker instance (e.g., [[hostname1, hostname2, ...], ...]). Use these to resolve the private IPs for NLB registration."
  value = aws_mq_broker.this[0].instances[*].endpoints
}
output "broker_id" {
  description = "Identifier for the Amazon MQ Broker"
  value       = length(aws_mq_broker.this) > 0 ? aws_mq_broker.this[0].id : null
}

output "broker_arn" {
  description = "ARN for the Amazon MQ Broker"
  value       = length(aws_mq_broker.this) > 0 ? aws_mq_broker.this[0].arn : null
}

output "broker_console_url" {
  description = "Direct web console endpoint for the broker"
  value       = length(aws_mq_broker.this) > 0 ? aws_mq_broker.this[0].instances[0].console_url : null
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer used for the broker."
  value = length(aws_lb.this) > 0 ? aws_lb.this[0].arn : null
}

output "target_group_arn" {
  value       = length(aws_lb_target_group.this) > 0 ? values(aws_lb_target_group.this)[0].arn : null
  description = "ARN of the first Target Group used for the broker. If multiple ports are exposed, this is the first."
}

output "target_group_name" {
  value       = length(aws_lb_target_group.this) > 0 ? values(aws_lb_target_group.this)[0].name : null
  description = "Name of the first Target Group used for the broker. If multiple ports are exposed, this is the first."
}

output "target_group_arns" {
  value       = [for tg in values(aws_lb_target_group.this) : tg.arn]
  description = "List of all Target Group ARNs used for the broker."
}

output "target_group_names" {
  value       = [for tg in values(aws_lb_target_group.this) : tg.name]
  description = "List of all Target Group names used for the broker."
}

