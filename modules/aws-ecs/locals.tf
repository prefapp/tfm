locals {
  ecs_load_balancer = [
    for lb in var.load_balancer : {
      target_group_arn = lb.target_group_arn != "" ? lb.target_group_arn : aws_lb_target_group.this.arn
      container_name   = lb.container_name
      container_port   = lb.container_port
    }
  ]
}
locals {
  vpc_by_id  = var.vpc_id != null && var.vpc_id != "" ? data.aws_vpc.by_id[0] : null
  vpc_by_tag = var.vpc_id == null && var.vpc_tag_name != "" ? data.aws_vpc.this[0] : null
  vpc_id     = try(local.vpc_by_id.id, local.vpc_by_tag.id)
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.this[0].ids
}
