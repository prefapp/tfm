data "aws_vpc" "this" {
  count = var.vpc_id == null && var.vpc_tag_name != "" ? 1 : 0
  filter {
    name   = "tag:${var.vpc_tag_key}"
    values = [var.vpc_tag_name]
  }
}

data "aws_vpc" "by_id" {
  count = var.vpc_id != null && var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "this" {
  count = var.subnet_ids == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  # Filtro de etiqueta comentado temporalmente para depuración
  # filter {
  #   name   = "tag:${var.subnet_tag_key}"
  #   values = [var.subnet_tag_name]
  # }
}
