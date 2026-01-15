resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0
  name  = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  count                    = var.service_name != null ? 1 : 0
  family                   = var.create_cluster ? aws_ecs_cluster.this[0].name : var.cluster_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.this[0].arn
  container_definitions    = var.container_definitions

  lifecycle {
    precondition {
      condition     = var.container_definitions != null
      error_message = "You must specify container_definitions."
    }
  }
}

locals {
  should_stop_service = (
    var.service_name != null &&
    var.service_name != null ? lookup(var.ecs_autoscaling, var.service_name, null) != null : false &&
    try(var.ecs_autoscaling[var.service_name].scale.stop, null) != null
  )
}

resource "aws_ecs_service" "this" {
  count           = var.service_name != null ? 1 : 0
  depends_on      = [aws_lb_target_group.this]
  name            = var.service_name
  cluster         = var.create_cluster ? aws_ecs_cluster.this[0].name : var.cluster_name
  task_definition = "${aws_ecs_task_definition.this[0].family}:${aws_ecs_task_definition.this[0].revision}"
  launch_type     = var.launch_type
  desired_count   = local.should_stop_service ? 0 : var.desired_count
  network_configuration {
    subnets          = local.resolved_subnets
    security_groups  = concat(var.security_groups, [aws_security_group.this[0].id])
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = (
      length(var.load_balancer) > 0 ? var.load_balancer :
      local.create_target_group ? [{
        target_group_arn = aws_lb_target_group.this[0].arn
        container_name   = jsondecode(var.container_definitions)[0].name
        container_port   = var.container_port
      }] : []
    )

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }
  lifecycle {

    precondition {
      condition     = var.service_name != null
      error_message = "You must specify service_name."
    }

    precondition {
      condition     = var.container_definitions != null
      error_message = "You must specify container_definitions."
    }

  }
}
