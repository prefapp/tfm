resource "aws_lb" "this" {
  count              = var.service_name != null ? var.create_alb ? 1 : 0 : 0
  name               = "${var.alb_name}-${var.service_name}"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this[0].id]
  subnets            = local.resolved_subnets
  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) > 0 || var.subnet_tag_name != ""
      error_message = "You must specify either subnet_ids or subnet_tag_name."
    }

    precondition {
      condition     = var.vpc_id != null || var.vpc_tag_name != ""
      error_message = "You must specify either vpc_id or vpc_tag_name."
    }
  }
}

resource "aws_lb_target_group" "this" {
  count       = var.service_name != null && (var.create_alb || var.existing_alb_name != null) ? 1 : 0
  name        = "${var.target_group_name}-${var.service_name}"
  port        = var.listener_port
  protocol    = var.listener_protocol
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check.path
    protocol            = var.health_check.protocol
    matcher             = var.health_check.matcher
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }
}

resource "aws_lb_listener" "this" {
  count             = var.service_name != null ? var.create_alb ? 1 : 0 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  certificate_arn = var.listener_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

# If an existing ALB is specified, use this

data "aws_lb" "this" {
  count = var.service_name != null ? var.existing_alb_name != null ? 1 : 0 : 0
  name  = var.existing_alb_name
}

data "aws_lb_listener" "this" {
  count             = var.service_name != null ? var.existing_alb_name != null ? 1 : 0 : 0
  load_balancer_arn = data.aws_lb.this[0].arn
  port              = var.listener_port
}


resource "aws_lb_listener_rule" "this" {
  count        = var.service_name != null ? var.existing_alb_name != null ? 1 : 0 : 0
  listener_arn = data.aws_lb_listener.this[0].arn
  priority     = var.alb_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  dynamic "condition" {
    for_each = var.static_content_host_header != null ? [1] : []
    content {
      host_header {
        values = [var.static_content_host_header]
      }
    }
  }

  dynamic "condition" {
    for_each = var.static_content_path_pattern != null ? [1] : []
    content {
      path_pattern {
        values = [var.static_content_path_pattern]
      }
    }
  }
  lifecycle {
    precondition {
      condition     = var.static_content_path_pattern != null || var.static_content_host_header != null
      error_message = "You must specify either static_content_path_pattern or static_content_host_header."
    }
  }

}

