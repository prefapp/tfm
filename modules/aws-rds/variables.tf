variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, pre, pro)"
  type        = string
}

variable "db_identifier" {
  description = "Unique identifier for the database instance (e.g., main, secondary)"
  type        = string
}

variable "vpc_tag_name" {
  description = "Tag name of the VPC to look up"
  type        = string
}

variable "subnet_tag_name" {
  description = "Tag name of the subnets to look up"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., postgres, mysql, mariadb)"
  type        = string
}

variable "db_port" {
  description = "Port for the database engine (e.g., 5432 for postgres, 3306 for mysql)"
  type        = number
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "main"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "db_name_ssm_name" {
  description = "SSM parameter name for the database name"
  type        = string
  default     = null
}

variable "db_username_ssm_name" {
  description = "SSM parameter name for the database username"
  type        = string
  default     = null
}

variable "db_password_ssm_name" {
  description = "SSM parameter name for the database password"
  type        = string
  default     = null
}

variable "db_endpoint_ssm_name" {
  description = "SSM parameter name for the database endpoint"
  type        = string
  default     = null
}

variable "db_host_ssm_name" {
  description = "SSM parameter name for the database host"
  type        = string
  default     = null
}

variable "db_port_ssm_name" {
  description = "SSM parameter name for the database port"
  type        = string
  default     = null
}

variable "security_group_name" {
  description = "Name of the security group for the RDS instance"
  type        = string
  default     = null
}

variable "subnet_group_name" {
  description = "Name of the DB subnet group for the RDS instance"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "Database engine version (e.g., 17.2 for postgres, 8.0 for mysql)"
  type        = string
}

variable "family" {
  description = "DB parameter group family (e.g., postgres17, mysql8.0)"
  type        = string
}

variable "manage_master_user_password" {
  description = "Whether to manage the master user password"
  type        = bool
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling"
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Whether to deploy in Multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 3
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Retention period for Performance Insights (in days)"
  type        = number
  default     = 7
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "Mon:00:00-Mon:02:00"
}

locals {
  default_ssm_prefix   = "${var.engine}/${var.environment}/${var.db_identifier}"
  db_name_ssm_name     = coalesce(var.db_name_ssm_name, "${local.default_ssm_prefix}/name")
  db_username_ssm_name = coalesce(var.db_username_ssm_name, "${local.default_ssm_prefix}/username")
  db_password_ssm_name = coalesce(var.db_password_ssm_name, "${local.default_ssm_prefix}/password")
  db_endpoint_ssm_name = coalesce(var.db_endpoint_ssm_name, "${local.default_ssm_prefix}/endpoint")
  db_host_ssm_name     = coalesce(var.db_host_ssm_name, "${local.default_ssm_prefix}/host")
  db_port_ssm_name     = coalesce(var.db_port_ssm_name, "${local.default_ssm_prefix}/port")
  security_group_name  = coalesce(var.security_group_name, "${var.engine}-${var.environment}-${var.db_identifier}-security-group")
  subnet_group_name    = coalesce(var.subnet_group_name, "${var.engine}-${var.environment}-${var.db_identifier}-subnet-group")
}
