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
  count = var.subnet_ids != null ? length(var.subnet_ids) : 0
  ids   = var.subnet_ids
}

data "aws_vpcs" "by_tag" {
  count = var.vpc_tags != null ? 1 : 0
  tags  = var.vpc_tags
}

data "aws_subnets" "by_tags" {
  count = var.subnet_tags != null ? 1 : 0
  tags  = var.subnet_tags

  # Optionally filter by VPC if one is specified either by ID or tags
  dynamic "filter" {
    for_each = (var.vpc_id != null || var.vpc_tags != null) ? [1] : []
    content {
      name   = "vpc-id"
      values = var.vpc_id != null ? [var.vpc_id] : data.aws_vpcs.by_tag[0].ids
    }
  }
}

