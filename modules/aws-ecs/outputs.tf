output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = try(aws_ecs_cluster.this[0].arn, "")
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = try(aws_ecs_cluster.this[0].name, "")
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = try(aws_ecs_service.this[0].id, "")
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = try(aws_ecs_service.this[0].name, "")
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = try(aws_ecs_task_definition.this[0].arn, "")
}

output "ecs_task_definition" {
  description = "ECS task definition resource object"
  value       = try(aws_ecs_task_definition.this[0], "")
}

output "security_group_id" {
  description = "ID of the security group used by the ECS service"
  value       = try(aws_security_group.this[0].id, "")
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = try(aws_lb.this[0].arn, "")
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = try(aws_lb_target_group.this[0].arn, "")
}

output "scale_up_policy_arns" {
  description = "ARNs of the scale up policies for each ECS service."
  value       = try({ for k, v in aws_appautoscaling_policy.scale_up : k => v.arn }, {})
}

output "scale_down_policy_arns" {
  description = "ARNs of the scale down policies for each ECS service."
  value       = try({ for k, v in aws_appautoscaling_policy.scale_down : k => v.arn }, {})
}

output "scale_up_alarm_arns" {
  description = "ARNs of the scale up CloudWatch alarms for each ECS service."
  value       = try({ for k, v in aws_cloudwatch_metric_alarm.scale_up_alarm : k => v.arn }, {})
}

output "scale_down_alarm_arns" {
  description = "ARNs of the scale down CloudWatch alarms for each ECS service."
  value       = try({ for k, v in aws_cloudwatch_metric_alarm.scale_down_alarm : k => v.arn }, {})
}


output "testing" {
  value = local.resolved_subnets
}

output "search" {
  value = data.aws_subnets.this[0].ids
}

output "localvpc_id" {
  value = local.vpc_id
}