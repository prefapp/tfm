/*
    This data source is used to get the current caller identity in order to
    get the account ID.

    DOC: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
*/
data "aws_caller_identity" "current" {
  count = local.eco_dr_enabled ? 0 : 1
}

#######################################
# VPC Lookup
#######################################

data "aws_vpc" "by_tags" {
  count = !local.eco_dr_enabled && var.vpc_tags != null ? 1 : 0
  dynamic "filter" {
    for_each = local.vpc_tag_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# Select the VPC for the EKS
# If we have a vpc_id, we will use that.
# If we don't, we will use the found vpc by tags
data "aws_vpc" "selected" {
  count = local.eco_dr_enabled ? 0 : 1

  id = coalesce(try(data.aws_vpc.by_tags[0].id, null), var.vpc_id)
}


#######################################
# Subnet Lookup
#######################################

data "aws_subnets" "filtered" {
  count = local.eco_dr_enabled ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }

  dynamic "filter" {
    for_each = local.subnet_tag_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# final subnet selection in locals.tf
