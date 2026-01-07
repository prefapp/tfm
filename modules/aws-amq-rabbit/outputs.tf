output "broker_id" {
  description = "Identifier for the Amazon MQ Broker"
  value       = aws_mq_broker.this.id
}

output "broker_arn" {
  description = "ARN for the Amazon MQ Broker"
  value       = aws_mq_broker.this.arn
}

output "broker_console_url" {
  description = "Direct web console endpoint for the broker"
  value       = aws_mq_broker.this.instances[0].console_url
}

output "nlb_dns_name" {
  description = "Static DNS name provided by the Network Load Balancer"
  value       = aws_lb.this.dns_name
}

output "nlb_arn" {
  description = "ARN for the Network Load Balancer"
  value       = aws_lb.this.arn
}

output "broker_security_group_id" {
  description = "ID of the security group protecting the broker"
  value       = aws_security_group.broker.id
}
