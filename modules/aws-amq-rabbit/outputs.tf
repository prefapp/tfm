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
  description = "ARN of the Target Group used for the broker."
  value = length(aws_lb_target_group.this) > 0 ? aws_lb_target_group.this[0].arn : null
}

output "target_group_name" {
  description = "Name of the Target Group used for the broker."
  value = length(aws_lb_target_group.this) > 0 ? aws_lb_target_group.this[0].name : null
}

output "nlb_dns_name" {
  description = "Static DNS name provided by the Network Load Balancer"
  value = length(aws_lb.this) > 0 ? aws_lb.this[0].dns_name : null
}

