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
  # Eliminado: la lógica de load_balancer se mueve al recurso para evitar problemas de dependencias
}
locals {
  vpc_by_id  = var.vpc_id != null && var.vpc_id != "" ? data.aws_vpc.by_id[0] : null
  vpc_by_tag = var.vpc_id == null && var.vpc_tag_name != "" ? data.aws_vpc.this[0] : null
  vpc_id     = try(local.vpc_by_id.id, local.vpc_by_tag.id)
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : []
}
