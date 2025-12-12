locals {
  vpc_by_id  = var.vpc_id != null && var.vpc_id != "" ? data.aws_vpc.by_id[0] : null
  vpc_by_tag = var.vpc_id == null && var.vpc_tag_name != "" ? data.aws_vpc.this[0] : null
  vpc_id     = try(local.vpc_by_id.id, local.vpc_by_tag.id)
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.this[0].ids
}
