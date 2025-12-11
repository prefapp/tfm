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


resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.name
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = var.launch_type
  desired_count   = 1
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }
}
