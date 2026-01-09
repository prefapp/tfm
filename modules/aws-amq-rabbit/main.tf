# -------------------------------------------------------------------------
# Optional Data Sources for Existing Resources
# -------------------------------------------------------------------------

data "aws_security_group" "existing" {
  count = var.existing_security_group_id != null ? 1 : 0
  id    = var.existing_security_group_id
}

data "aws_lb" "existing" {
  count = var.existing_lb_arn != null ? 1 : 0
  arn   = var.existing_lb_arn
}

data "aws_lb_target_group" "existing" {
  count = var.existing_target_group_arn != null ? 1 : 0
  arn   = var.existing_target_group_arn
}
# -------------------------------------------------------------------------
# Networking Resolution
# -------------------------------------------------------------------------

data "aws_vpc" "this" {
  count = var.vpc_id == null && var.vpc_name != null ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "broker" {
  count = length(var.broker_subnet_ids) == 0 && length(var.broker_subnet_filter_tags) > 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  dynamic "filter" {
    for_each = var.broker_subnet_filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

data "aws_subnets" "lb" {
  count = length(var.lb_subnet_ids) == 0 && length(var.lb_subnet_filter_tags) > 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  dynamic "filter" {
    for_each = var.lb_subnet_filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : one(data.aws_vpc.this[*].id)
  single_broker_subnet_id = (
    length(var.broker_subnet_ids) > 0
    ? var.broker_subnet_ids[0]
    : (
        length(one(data.aws_subnets.broker[*].ids)) > 0
        ? one(data.aws_subnets.broker[*].ids)[0]
        : null
      )
  )
  broker_subnet_ids = (
    var.deployment_mode == "SINGLE_INSTANCE"
    ? [local.single_broker_subnet_id]
    : (length(var.broker_subnet_ids) > 0 ? var.broker_subnet_ids : one(data.aws_subnets.broker[*].ids))
  )
  lb_subnet_ids = length(var.lb_subnet_ids) > 0 ? var.lb_subnet_ids : one(data.aws_subnets.lb[*].ids)

  name_prefix = "mq-service-${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Source      = "Terraform-Module"
  })
}

# -------------------------------------------------------------------------
# Security Configuration
# -------------------------------------------------------------------------

resource "aws_security_group" "this" {
  count       = var.existing_security_group_id == null ? 1 : 0
  name        = "${local.name_prefix}-sg"
  description = "Access control for MQ Broker"
  vpc_id      = local.vpc_id

  ingress {
    description = "AMQPS-Traffic"
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }

  ingress {
    description = "Management-UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# -------------------------------------------------------------------------
# Amazon MQ Broker (RabbitMQ)
# -------------------------------------------------------------------------

resource "aws_mq_broker" "this" {
  count = contains(["public", "private"], var.access_mode) ? 1 : 0
  broker_name = local.name_prefix

  engine_type         = "RabbitMQ"
  engine_version      = var.engine_version
  host_instance_type  = var.host_instance_type
  deployment_mode     = var.deployment_mode
  subnet_ids          = local.broker_subnet_ids
  security_groups     = var.existing_security_group_id != null ? [var.existing_security_group_id] : [aws_security_group.this[0].id]
  publicly_accessible = var.access_mode == "public" ? true : false
  storage_type        = "ebs"

  auto_minor_version_upgrade = true

  user {
    username = var.mq_username
    password = var.mq_password
  }

  logs {
    general = var.enable_cloudwatch_logs
  }

  tags = local.common_tags
}

# -------------------------------------------------------------------------
# Infrastructure Connectivity (NLB)
# -------------------------------------------------------------------------

resource "aws_lb" "this" {
  count               = var.existing_lb_arn == null && var.access_mode == "private_with_nlb" ? 1 : 0
  name                = "${local.name_prefix}-nlb"
  internal            = false
  load_balancer_type  = "network"
  subnets             = local.lb_subnet_ids
  tags                = local.common_tags
}

resource "aws_lb_target_group" "this" {
  count       = var.existing_target_group_arn == null && var.access_mode == "private_with_nlb" ? 1 : 0
  name        = "${local.name_prefix}-tg"
  port        = 5671
  protocol    = "TLS"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    enabled  = true
    protocol = "HTTPS"
    port     = "443"
    path     = "/"
  }
}

resource "aws_lb_listener" "this" {
  count             = var.existing_lb_arn == null && var.existing_target_group_arn == null && var.access_mode == "private_with_nlb" ? 1 : 0
  load_balancer_arn = var.existing_lb_arn != null ? var.existing_lb_arn : aws_lb.this[0].arn
  port              = 5671
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.existing_target_group_arn != null ? var.existing_target_group_arn : aws_lb_target_group.this[0].arn
  }
}

