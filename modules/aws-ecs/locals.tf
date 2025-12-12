resource "null_resource" "debug_vpc_and_subnets" {
  provisioner "local-exec" {
    command = <<EOT
      echo "[DEBUG] VPC_ID: ${local.vpc_id}"
      echo "[DEBUG] DATA_SUBNET_IDS: ${join(",", try(data.aws_subnets.this[0].ids, []))}"
    EOT
  }
  triggers = {
    vpc_id         = local.vpc_id
    data_subnet_ids = join(",", try(data.aws_subnets.this[0].ids, []))
  }
}
resource "null_resource" "debug_subnet_ids" {
  provisioner "local-exec" {
    command = "echo SUBNET_IDS: ${join(",", local.subnet_ids)}"
  }
}
locals {
  default_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  ecs_assume_role_policy = var.assume_role_policy != "" ? var.assume_role_policy : local.default_assume_role_policy
}
locals {
  ecs_load_balancer = [
    for lb in var.load_balancer : {
      target_group_arn = try(lb.target_group_arn, "") != "" ? lb.target_group_arn : aws_lb_target_group.this.arn
      container_name   = lb.container_name
      container_port   = lb.container_port
    }
  ]
}
locals {
  vpc_by_id  = var.vpc_id != null && var.vpc_id != "" ? data.aws_vpc.by_id[0] : null
  vpc_by_tag = var.vpc_id == null && var.vpc_tag_name != "" ? data.aws_vpc.this[0] : null
  vpc_id     = try(local.vpc_by_id.id, local.vpc_by_tag.id)
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : []
}
