data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_tag_name]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:type"
    values = [var.subnet_tag_name]
  }
}

resource "random_password" "this" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_ssm_parameter" "db_name" {
  name        = local.db_name_ssm_name
  description = "${var.engine} database name"
  type        = "String"
  value       = var.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name        = local.db_username_ssm_name
  description = "${var.engine} database username"
  type        = "String"
  value       = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name        = local.db_password_ssm_name
  description = "${var.engine} database password"
  type        = "SecureString"
  value       = random_password.this.result
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = local.db_endpoint_ssm_name
  description = "${var.engine} database endpoint"
  type        = "String"
  value       = module.rds.db_instance_endpoint
}

resource "aws_ssm_parameter" "db_host" {
  name        = local.db_host_ssm_name
  description = "${var.engine} database host"
  type        = "String"
  value       = module.rds.db_instance_address
}

resource "aws_ssm_parameter" "db_port" {
  name        = local.db_port_ssm_name
  description = "${var.engine} database port"
  type        = "String"
  value       = module.rds.db_instance_port
}

resource "aws_security_group" "this" {
  name        = local.security_group_name
  description = "${var.engine} database security group"
  vpc_id      = data.aws_vpc.this.id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_db_subnet_group" "this" {
  name        = local.subnet_group_name
  subnet_ids  = data.aws_subnets.this.ids
  description = "${var.engine} subnet group"
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier                  = var.db_identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  family                      = var.family
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  manage_master_user_password = var.manage_master_user_password

  username = aws_ssm_parameter.db_username.value
  password = aws_ssm_parameter.db_password.value
  db_name  = aws_ssm_parameter.db_name.value
  port     = var.db_port

  deletion_protection                   = var.deletion_protection
  max_allocated_storage                 = var.max_allocated_storage
  multi_az                              = var.multi_az
  backup_retention_period               = var.backup_retention_period
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  publicly_accessible                   = var.publicly_accessible
  maintenance_window                    = var.maintenance_window
  backup_window                         = var.backup_window
  storage_type                          = var.storage_type
  iops                                  = var.iops
  parameters                            = var.parameters
  apply_immediately                     = var.apply_immediately
  allow_major_version_upgrade           = var.allow_major_version_upgrade
}
