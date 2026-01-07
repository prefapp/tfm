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
  vpc_id            = var.vpc_id != null ? var.vpc_id : one(data.aws_vpc.this[*].id)
  broker_subnet_ids = length(var.broker_subnet_ids) > 0 ? var.broker_subnet_ids : one(data.aws_subnets.broker[*].ids)
  lb_subnet_ids     = length(var.lb_subnet_ids) > 0 ? var.lb_subnet_ids : one(data.aws_subnets.lb[*].ids)

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
  broker_name = local.name_prefix

  engine_type         = "RabbitMQ"
  engine_version      = var.engine_version
  host_instance_type  = var.host_instance_type
  deployment_mode     = var.deployment_mode
  subnet_ids          = local.broker_subnet_ids
  security_groups     = [aws_security_group.this.id]
  publicly_accessible = false
  storage_type        = "ebs"

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
  name               = "${local.name_prefix}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = local.lb_subnet_ids

  tags = local.common_tags
}

resource "aws_lb_target_group" "this" {
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
  load_balancer_arn = aws_lb.this.arn
  port              = 5671
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# -------------------------------------------------------------------------
# Broker-NLB Glue Logic (ENI Association)
# -------------------------------------------------------------------------

data "aws_network_interface" "broker_eni" {
  for_each = toset(aws_mq_broker.this.instances[*].ip_address)

  filter {
    name   = "description"
    values = ["DO NOT DELETE - Amazon MQ Broker ${aws_mq_broker.this.id} Interface*"]
  }

  filter {
    name   = "private-ip-address"
    values = [each.value]
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = data.aws_network_interface.broker_eni

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value.private_ip
  port             = 5671
}
