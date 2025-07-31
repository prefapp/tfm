data "aws_vpc" "this" {
  count = var.vpc_id == null && var.vpc_tag_name != "" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_tag_name]
  }
}

data "aws_vpc" "by_id" {
  count = var.vpc_id != null && var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "this" {
  count = var.subnet_ids == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:type"
    values = [var.subnet_tag_name]
  }
}

resource "aws_secretsmanager_secret" "rds" {
  count       = var.use_secrets_manager ? 1 : 0
  name        = "${var.engine}-${var.environment}-${var.db_identifier}"
  description = "RDS credentials for ${var.engine}-${var.environment}-${var.db_identifier}"
}

resource "aws_secretsmanager_secret_version" "rds" {
  count     = var.use_secrets_manager ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.this.result
    host     = module.rds.db_instance_address
    port     = var.db_port
    endpoint = module.rds.db_instance_endpoint
    dbname   = var.db_name
  })
  depends_on = [module.rds]
}

resource "random_password" "this" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_ssm_parameter" "db_name" {
  count       = var.use_secrets_manager ? 0 : 1
  name        = local.db_name_ssm_name
  description = "${var.engine} database name"
  type        = "String"
  value       = var.db_name
}

resource "aws_ssm_parameter" "db_username" {
  count       = var.use_secrets_manager ? 0 : 1
  name        = local.db_username_ssm_name
  description = "${var.engine} database username"
  type        = "String"
  value       = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  count       = var.use_secrets_manager ? 0 : 1
  name        = local.db_password_ssm_name
  description = "${var.engine} database password"
  type        = "SecureString"
  value       = random_password.this.result
}

resource "aws_ssm_parameter" "db_endpoint" {
  count       = var.use_secrets_manager ? 0 : 1
  name        = local.db_endpoint_ssm_name
  description = "${var.engine} database endpoint"
  type        = "String"
  value       = module.rds.db_instance_endpoint
}

resource "aws_ssm_parameter" "db_host" {
  count       = var.use_secrets_manager ? 0 : 1
  name        = local.db_host_ssm_name
  description = "${var.engine} database host"
  type        = "String"
  value       = module.rds.db_instance_address
}

resource "aws_ssm_parameter" "db_port" {
  count       = var.use_secrets_manager ? 0 : 1
  name        = local.db_port_ssm_name
  description = "${var.engine} database port"
  type        = "String"
  value       = module.rds.db_instance_port
}

data "aws_security_group" "by_tag" {
  count = var.security_group_id == null && var.security_group_tag_name != "" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.security_group_tag_name]
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_security_group" "by_id" {
  count = var.security_group_id != null ? 1 : 0
  id    = var.security_group_id
}


resource "aws_security_group" "this" {
  count       = local.use_existing_sg ? 0 : 1
  name        = local.security_group_name
  description = "${var.engine} database security group"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  count             = local.use_existing_sg ? 0 : 1
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  cidr_blocks       = [local.vpc_cidr]
}

resource "aws_security_group_rule" "egress" {
  count             = local.use_existing_sg ? 0 : 1
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this[0].id
  cidr_blocks       = [local.vpc_cidr]
}

resource "aws_security_group_rule" "extra" {
  for_each = !local.use_existing_sg ? {
    for i, rule in var.extra_security_group_rules : "${rule.type}-${i}" => rule
  } : {}

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this[0].id

  cidr_blocks      = lookup(each.value, "cidr_blocks", [])
  ipv6_cidr_blocks = lookup(each.value, "ipv6_cidr_blocks", [])
  prefix_list_ids  = lookup(each.value, "prefix_list_ids", [])
  description      = lookup(each.value, "description", null)
  self             = lookup(each.value, "self", null)
}

resource "aws_db_subnet_group" "this" {
  name        = local.subnet_group_name
  subnet_ids  = local.subnet_ids
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
  vpc_security_group_ids      = [local.security_group_id]
  manage_master_user_password = var.manage_master_user_password

  username = var.manage_master_user_password ? null : var.db_username
  password = var.manage_master_user_password ? null : random_password.this.result
  db_name  = var.db_name
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
