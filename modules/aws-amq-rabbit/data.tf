data "aws_vpc" "this" {
  count = var.vpc_id != null ? 1 : 0
  id    = var.vpc_id
}

data "aws_vpc" "by_name" {
  count = var.vpc_id == null && var.vpc_name != null ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "broker" {
  count = length(var.broker_subnet_ids) == 0 && length(var.broker_subnet_filter_tags) > 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  dynamic "filter" {
    for_each = var.broker_subnet_filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

data "aws_subnets" "lb" {
  count = length(var.lb_subnet_ids) == 0 && length(var.lb_subnet_filter_tags) > 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  dynamic "filter" {
    for_each = var.lb_subnet_filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}
