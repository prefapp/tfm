resource "random_password" "mq_password" {
  length  = 30
  special = true
  upper   = true
  lower   = true
  numeric = true
  # Amazon MQ does not allow: [, ], :, =, ,
  override_special = "!#$%&()*+-.;<>?@^_{|}~"
}

resource "aws_ssm_parameter" "mq_password" {
  name        = "/${var.project_name}/${var.environment}/mq/broker_password"
  description = "Amazon MQ broker password for ${var.project_name} (${var.environment})"
  type        = "SecureString"
  value       = random_password.mq_password.result
  overwrite   = true
  tags        = local.common_tags

  # Prevent replacement of the SSM parameter unless the name changes, to avoid accidental password rotation
  lifecycle {
    ignore_changes = [value]
  }

  # NOTE: By default, the password will not be rotated on every apply. If you want to rotate the password, you must taint or manually update this resource.
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
    cidr_blocks = [var.vpc_id != null ? data.aws_vpc.this[0].cidr_block : data.aws_vpc.by_name[0].cidr_block]
    description = "Allow RabbitMQ (5671) from VPC CIDR"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_id != null ? data.aws_vpc.this[0].cidr_block : data.aws_vpc.by_name[0].cidr_block]
    description = "Allow HTTPS (443) from VPC CIDR"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.common_tags
}

resource "aws_mq_broker" "this" {
  broker_name         = local.name_prefix
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
  count              = var.access_mode == "private_with_nlb" ? 1 : 0
  name               = "${local.name_prefix}-nlb"
  internal           = contains(["private", "private_with_nlb"], var.access_mode)
  load_balancer_type = "network"
  subnets            = local.lb_subnet_ids
  tags               = local.common_tags
}




resource "aws_lb_target_group" "this" {
  for_each = var.access_mode == "private_with_nlb" ? { for cfg in local.nlb_listener_configs : cfg.port_key => cfg } : {}
  # Ensure the total name length (prefix + port_key) does not exceed 32 characters
  name        = replace("${substr(local.tg_name_prefix, 0, max(0, 32 - length(each.key)))}${each.key}", "-+$", "")
  port        = each.value.target_port
  protocol    = "TLS"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    enabled  = true
    protocol = "TLS"
    port     = "traffic-port"
    # No 'path' parameter for TLS health checks
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
    for pair in flatten([
      for cfg in local.nlb_listener_configs : [
        for ip in cfg.ips : {
          "${cfg.port_key}-${ip}" = {
            tg_arn = aws_lb_target_group.this[cfg.port_key].arn
            port   = cfg.target_port
            ip     = ip
          }
        }
      ]
    ]) : pair
  ]...) : {}

  target_group_arn = each.value.tg_arn
  target_id        = each.value.ip
  port             = each.value.port

  depends_on = [aws_mq_broker.this]
}
