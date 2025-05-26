/*
    This data source is used to get the current caller identity in order to
    get the account ID.

    DOC: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
*/
data "aws_caller_identity" "current" {}

data "aws_vpc" "by_id" {
  count = var.vpc_id != null ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "by_ids" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

data "aws_vpcs" "by_tag" {
  count = var.vpc_tags != null ? 1 : 0
  tags  = var.vpc_tags
}

data "aws_subnets" "by_tags" {
  count = var.subnet_tags != null ? length(data.aws_vpcs_by_tags[0].ids) : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.by_tag[0].ids[count.index]]
  }

  tags = var_subnet_tags
}

