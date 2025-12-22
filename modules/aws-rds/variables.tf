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

variable "vpc_id" {
  description = "ID of the VPC where the RDS instance will be deployed. If not set, vpc_tag_name will be used to look up the VPC."
  type        = string
  default     = null
}

variable "vpc_tag_key" {
  description = "Tag key used to search the VPC when vpc_id is not provided"
  type        = string
  default     = "Name"
}

variable "vpc_tag_name" {
  description = "Tag name of the VPC to look up"
  type        = string
  default     = ""
  validation {
    condition     = var.vpc_id != null || var.vpc_tag_name != ""
    error_message = "You must specify either vpc_id or vpc_tag_name."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group. If not set, subnet_tag_name will be used."
  type        = list(string)
  default     = null
}

variable "subnet_tag_key" {
  description = "Tag key used to search the subnets when subnet_ids is not provided"
  type        = string
  default     = "type"
}

variable "subnet_tag_name" {
  description = "Tag name of the subnets to look up"
  type        = string
  default     = ""
  validation {
    condition     = var.subnet_ids != null || var.subnet_tag_name != ""
    error_message = "You must specify either subnet_ids or subnet_tag_name."
  }
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

variable "security_group_id" {
  description = "ID of an existing security group. If set, the module will not create a new one."
  type        = string
  default     = null
}

variable "security_group_tag_name" {
  description = "Tag name of the existing security group to look up (only used if security_group_id is not set)."
  type        = string
  default     = ""
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
  description = "Whether to let RDS manage the master password with automatic Secrets Manager integration. If `true`, disables local creation of Secrets Manager or SSM password."
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

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "Type of storage (e.g., standard, gp2, gp3, io1)"
  type        = string
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS. Required if storage_type is io1 or gp3"
  type        = number
  default     = null
}

variable "parameters" {
  description = "List of DB parameters to apply (parameter group will be created automatically)"
  type        = list(any)
  default     = []
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Whether to allow major version upgrades"
  type        = bool
  default     = false
}

variable "extra_security_group_rules" {
  description = <<EOF
List of extra security group rules to add to the managed security group.
Only used if the security group is created by the module (i.e. no `security_group_id` or `security_group_tag_name` is given).
Each rule must include the same arguments used in `aws_security_group_rule`, except `security_group_id`.
EOF
  type = list(object({
    type             = string # "ingress" or "egress"
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    prefix_list_ids  = optional(list(string))
    description      = optional(string)
    self             = optional(bool)
  }))
  default = []
}

variable "use_secrets_manager" {
  description = "If true, store RDS credentials in AWS Secrets Manager instead of SSM Parameter Store"
  type        = bool
  default     = false
  validation {
    condition     = !(var.manage_master_user_password && var.use_secrets_manager)
    error_message = "When manage_master_user_password is true, the module manages the secret. Do not set use_secrets_manager = true."
  }
}

variable "manage_master_user_password_rotation" {
  description = "Whether to enable automatic password rotation for the master user secret (only applies if `manage_master_user_password = true`)"
  type    = bool
  default = false
  validation {
    condition     = !var.manage_master_user_password_rotation || (var.manage_master_user_password)
    error_message = "'manage_master_user_password_rotation' requires 'manage_master_user_password = true'."
  }
}

variable "master_user_password_rotate_immediately" {
  description = "Whether to rotate the master user password immediately upon creation"
  type        = bool
  default     = false
  validation {
    condition     = !var.master_user_password_rotate_immediately || var.manage_master_user_password_rotation
    error_message = "'master_user_password_rotate_immediately' requires 'manage_master_user_password_rotation = true'."
  }
}

variable "master_user_password_rotation_automatically_after_days" {
  description = "Number of days after which the master password should be rotated automatically"
  type        = number
  default     = null
  validation {
    condition     = var.master_user_password_rotation_automatically_after_days == null || var.manage_master_user_password_rotation
    error_message = "'master_user_password_rotation_automatically_after_days' requires 'manage_master_user_password_rotation = true'."
  }
}

variable "master_user_password_rotation_duration" {
  description = "Duration of the rotation event (e.g., 1h, PT5M, ...)"
  type        = string
  default     = null
  validation {
    condition     = var.master_user_password_rotation_duration == null || var.manage_master_user_password_rotation
    error_message = "'master_user_password_rotation_duration' requires 'manage_master_user_password_rotation = true'."
  }
}

variable "master_user_password_rotation_schedule_expression" {
  description = "Schedule expression for password rotation (e.g., `rate(30 days)`)"
  type        = string
  default     = null
  validation {
    condition     = var.master_user_password_rotation_schedule_expression == null || var.manage_master_user_password_rotation
    error_message = "'master_user_password_rotation_schedule_expression' requires 'manage_master_user_password_rotation = true'."
  }
  validation {
    condition     = var.master_user_password_rotation_automatically_after_days == null || var.master_user_password_rotation_schedule_expression == null
    error_message = "Only one of 'master_user_password_rotation_automatically_after_days' or 'master_user_password_rotation_schedule_expression' should be set."
  }
}
