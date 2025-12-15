resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = aws_ecs_cluster.this.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.this.arn
  container_definitions    = var.container_definitions
}

locals {
  should_stop_service = lookup(var.ecs_autoscaling, var.service_name, null) != null && try(var.ecs_autoscaling[var.service_name].scale.stop, null) != null
}

resource "aws_ecs_service" "this" {
  depends_on     = [aws_lb_target_group.this]
  name           = var.service_name
  cluster        = aws_ecs_cluster.this.name
  task_definition = "${aws_ecs_task_definition.this.family}:${aws_ecs_task_definition.this.revision}"
  launch_type    = var.launch_type
  desired_count  = local.should_stop_service ? 0 : var.desired_count
  network_configuration {
    subnets          = local.resolved_subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = coalesce(load_balancer.value.target_group_arn, aws_lb_target_group.this.arn)
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }
}
