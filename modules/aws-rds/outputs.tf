output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = module.rds.db_instance_port
}

output "db_name" {
  description = "The name of the database"
  value       = var.use_secrets_manager ? null : aws_ssm_parameter.db_name[0].value
}

output "db_username" {
  description = "The username for the database"
  value       = var.use_secrets_manager ? null : aws_ssm_parameter.db_username[0].value
}

output "db_password_ssm_name" {
  description = "The name of the SSM parameter storing the database password"
  value       = var.use_secrets_manager ? null : aws_ssm_parameter.db_password[0].name
}

output "security_group_id" {
  description = "The ID of the security group for the RDS instance"
  value       = local.security_group_id
}

output "subnet_group_name" {
  description = "The name of the DB subnet group for the RDS instance"
  value       = aws_db_subnet_group.this.name
}

output "secrets_manager_arn" {
  value       = var.use_secrets_manager ? aws_secretsmanager_secret.rds[0].arn : null
  description = "ARN of the RDS secrets stored in Secrets Manager (null if not used)"
}

