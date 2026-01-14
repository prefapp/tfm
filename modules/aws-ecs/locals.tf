locals {
  # IAM assume role policy
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

  # VPC resolution
  vpc_by_id  = (var.vpc_id != null && var.vpc_id != "") ? data.aws_vpc.by_id[0] : null
  vpc_by_tag = (var.vpc_id == null && var.vpc_tag_name != "") ? data.aws_vpc.this[0] : null
  vpc_id     = var.service_name != null ? try(local.vpc_by_id.id, local.vpc_by_tag.id) : null

  # Subnet resolution
  resolved_subnets = (
    var.subnet_ids != null && length(var.subnet_ids) > 0
  ) ? var.subnet_ids : var.service_name != null ? try(data.aws_subnets.this[0].ids, []) : []


  # Target group creation condition
  create_target_group = (
    var.service_name != null &&
    (
      var.create_alb ||
      var.existing_alb_name != null
    )
  )


}
