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
  value       = var.db_name
}

output "db_username" {
  description = "The username for the database"
  value       = var.db_username
}

output "db_password_ssm_name" {
  description = "The name of the SSM parameter storing the database password"
  value       = var.use_secrets_manager || var.manage_master_user_password ? null : aws_ssm_parameter.db_password[0].name
}

output "db_name_ssm_name" {
  description = "The name of the SSM parameter storing the database name"
  value       = var.manage_master_user_password || !var.use_secrets_manager ? local.db_name_ssm_name : null
}

output "db_username_ssm_name" {
  description = "The name of the SSM parameter storing the database username"
  value       = var.use_secrets_manager || var.manage_master_user_password ? null : local.db_username_ssm_name
}

output "db_endpoint_ssm_name" {
  description = "The name of the SSM parameter storing the database endpoint"
  value       = var.manage_master_user_password || !var.use_secrets_manager ? local.db_endpoint_ssm_name : null
}

output "db_host_ssm_name" {
  description = "The name of the SSM parameter storing the database host"
  value       = var.manage_master_user_password || !var.use_secrets_manager ? local.db_host_ssm_name : null
}

output "db_port_ssm_name" {
  description = "The name of the SSM parameter storing the database port"
  value       = var.manage_master_user_password || !var.use_secrets_manager ? local.db_port_ssm_name : null
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
  description = "ARN of the RDS secrets stored in Secrets Manager (null if not used)"
  value       = var.manage_master_user_password || !var.use_secrets_manager ? null : aws_secretsmanager_secret.rds[0].arn
}

output "master_user_secret_arn" {
  description = "RDS-managed secret ARN (if applicable)"
  value       = var.manage_master_user_password ? module.rds.db_instance_master_user_secret_arn : null
}
