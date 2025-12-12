data "aws_vpc" "this" {
  count = var.vpc_id != "" ? 0 : 1
  filter {
    name   = var.vpc_filter_name
    values = [var.vpc_filter_value]
  }
}

data "aws_subnets" "this" {
  count = length(var.subnet_ids) > 0 ? 0 : 1
  filter {
    name   = var.subnet_filter_name
    values = [var.subnet_filter_value]
  }
}
