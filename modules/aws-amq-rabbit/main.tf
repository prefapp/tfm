
locals {
  broker_security_groups = contains(["private", "private_with_nlb"], var.access_mode) ? (
      var.existing_security_group_id != null ? [var.existing_security_group_id] : [aws_security_group.this[0].id]
    ) : null

  # AWS Target Group name limit is 32 chars. AWS appends a 6-char random suffix, so we have 26 chars for our prefix.
  # We use up to 21 chars for the base prefix and 5 for the port (max 65535), e.g. 'prefix-p65535-'.
  tg_name_prefix = "${substr(local.name_prefix, 0, 21)}-p"
  # Map well-known RabbitMQ ports to service names for SG descriptions
  rabbitmq_port_names = {
    5671  = "AMQPS"
    15672 = "Management UI"
  }
  vpc_id = var.vpc_id != null ? var.vpc_id : one(data.aws_vpc.by_name[*].id)
  vpc_cidr_block = var.vpc_id != null ? one(data.aws_vpc.this[*].cidr_block) : one(data.aws_vpc.by_name[*].cidr_block)
  single_broker_subnet_id = (
    length(var.broker_subnet_ids) > 0
    ? var.broker_subnet_ids[0]
    : (
        length(try(one(data.aws_subnets.broker[*].ids), [])) > 0
        ? try(one(data.aws_subnets.broker[*].ids)[0], null)
        : null
      )
  )
  broker_subnet_ids = (
    var.deployment_mode == "SINGLE_INSTANCE"
    ? (local.single_broker_subnet_id != null ? [local.single_broker_subnet_id] : [])
    : (length(var.broker_subnet_ids) > 0 ? var.broker_subnet_ids : try(one(data.aws_subnets.broker[*].ids), []))
  )

  lb_subnet_ids = length(var.lb_subnet_ids) > 0 ? var.lb_subnet_ids : one(data.aws_subnets.lb[*].ids)


  name_prefix = "mq-service-${var.project_name}-${var.environment}"


  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    Source      = "Terraform-Module"
  })
}

resource "aws_security_group" "this" {
  count       = var.existing_security_group_id == null ? 1 : 0
  name        = "${local.name_prefix}-sg"
  description = "Access control for MQ Broker"
  vpc_id      = local.vpc_id



  dynamic "ingress" {
    for_each = var.exposed_ports
    content {
      description = "RabbitMQ ${lookup(local.rabbitmq_port_names, ingress.value, "Custom Port")} (${ingress.value})"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidrs
    }
  }

  # Allow RabbitMQ (5671) and HTTPS (443) from within the VPC
  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this[0].cidr_block]
    description = "Allow RabbitMQ (5671) from VPC CIDR"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this[0].cidr_block]
    description = "Allow HTTPS (443) from VPC CIDR"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

## Password for Amazon MQ Broker
resource "random_password" "mq_password" {
  length           = 30
  special          = true
  # Exclude invalid Amazon MQ password characters: [, ], :, =, , (comma)
  override_special = "!#$%&()*+-.;<>?@^_{|}~"
}

resource "aws_ssm_parameter" "mq_password" {
  name        = "/${var.project_name}/${var.environment}/mq/broker_password"
  description = "Password for Amazon MQ Broker in project ${var.project_name} and environment ${var.environment}"
  type        = "SecureString"
  value       = random_password.mq_password.result
  tags        = local.common_tags
  lifecycle {
    ignore_changes = [value]
  }
}


# -------------------------------------------------------------------------
# Amazon MQ Broker (RabbitMQ)
# -------------------------------------------------------------------------
# Creates the RabbitMQ broker with the specified configuration.
# -------------------------------------------------------------------------
# NOTE: count is set to 1 to ensure subsequent executions of terraform apply with this module
# doesn't destroy the broker if not present, for example, if we use the module to attach
# a NLB to an existing broker.
# -------------------------------------------------------------------------
resource "aws_mq_broker" "this" {
  count = 1
  broker_name = local.name_prefix

  engine_type         = "RabbitMQ"
  engine_version      = var.engine_version
  host_instance_type  = var.host_instance_type
  deployment_mode     = var.deployment_mode
  subnet_ids          = local.broker_subnet_ids
  security_groups     = local.broker_security_groups
  publicly_accessible = var.access_mode == "public" ? true : false
  storage_type        = "ebs"

  auto_minor_version_upgrade = true

  user {
    username = var.mq_username
    password = aws_ssm_parameter.mq_password.value
  }

  logs {
    general = var.enable_cloudwatch_logs
  }

  tags = local.common_tags
}

# -------------------------------------------------------------------------
# Infrastructure Connectivity (NLB)
# -------------------------------------------------------------------------
#
# This part is only needed if access_mode is set to "private_with_nlb"
#
resource "aws_lb" "this" {
  count               = var.access_mode == "private_with_nlb" ? 1 : 0
  name                = "${local.name_prefix}-nlb"
  internal            = contains(["private", "private_with_nlb"], var.access_mode)
  load_balancer_type  = "network"
  subnets             = local.lb_subnet_ids
  tags                = local.common_tags
}



locals {
  # Build a list of listener/target group configs from nlb_listener_ips
  nlb_listener_configs = var.access_mode == "private_with_nlb" ? flatten([
    for entry in var.nlb_listener_ips : (
      (lookup(entry, "expose_all_ports", false)) ? [
        for port, name in local.rabbitmq_port_names : {
          target_port   = port
          listener_port = port
          ips           = entry.ips
          port_key      = tostring(port)
        }
      ] : [
        {
          target_port   = (can(tonumber(lookup(entry, "target_port", null))) ? tonumber(entry.target_port) : lookup(local.rabbitmq_port_names, entry.target_port, null))
          listener_port = lookup(entry, "listener_port", null) != null ? entry.listener_port : (can(tonumber(lookup(entry, "target_port", null))) ? tonumber(entry.target_port) : lookup(local.rabbitmq_port_names, entry.target_port, null))
          ips           = entry.ips
          port_key      = tostring(lookup(entry, "listener_port", null) != null ? entry.listener_port : entry.target_port)
        }
      ]
    )
  ]) : []
}

resource "aws_lb_target_group" "this" {
  for_each = var.access_mode == "private_with_nlb" ? { for cfg in local.nlb_listener_configs : cfg.port_key => cfg } : {}
  name        = trimend(substr("${local.tg_name_prefix}${each.key}", 0, 32), "-")
  port        = each.value.target_port
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
  for_each          = var.access_mode == "private_with_nlb" ? { for cfg in local.nlb_listener_configs : cfg.port_key => cfg } : {}
  load_balancer_arn = aws_lb.this[0].arn
  port              = each.value.listener_port
  protocol          = "TLS"
  ssl_policy        = var.lb_ssl_policy
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}

# -------------------------------------------------------------------------
# Register Broker Private IPs as NLB Targets
# -------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "broker" {
  for_each = var.access_mode == "private_with_nlb" ? merge([
    for cfg in local.nlb_listener_configs : [
      for ip in cfg.ips : {
        "${cfg.port_key}-${ip}" = {
          tg_arn = aws_lb_target_group.this[cfg.port_key].arn
          port   = cfg.target_port
          ip     = ip
        }
      }
    ]
  ]...) : {}

  target_group_arn = each.value.tg_arn
  target_id        = each.value.ip
  port             = each.value.port

  depends_on = [aws_mq_broker.this]
}
