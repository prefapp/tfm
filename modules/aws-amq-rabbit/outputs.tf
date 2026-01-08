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

output "broker_private_ips" {
  description = "List of private IPs of the broker instances"
  value       = length(aws_mq_broker.this) > 0 ? aws_mq_broker.this[0].instances[*].ip_address : []
}

output "nlb_dns_name" {
  description = "Static DNS name provided by the Network Load Balancer"
  value       = length(aws_lb.this) > 0 ? aws_lb.this[0].dns_name : null
}

output "broker_security_group_id" {
  description = "ID of the security group protecting the broker"
  value       = aws_security_group.this.id
}
