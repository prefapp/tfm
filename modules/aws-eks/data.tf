/*
    This data source is used to get the current caller identity in order to
    get the account ID.

    DOC: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
*/
data "aws_caller_identity" "current" {}

/*
  This data source is used to get the VPC ID in order to create the EKS cluster.
*/
data "aws_vpc" "by_tag" {
  count = var.vpc_name != null ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}


/*
  Get private subents in the VPC by tag (provided as variable)
*/
data "aws_subnets" "private_by_tag" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }

  filter {
    name   = "tag:${var.subnet_tag}"
    values = [var.subnet_tag_value]
  }
}

data "aws_vpc" "by_tags" {
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
  id = coalesce(try(data.aws_vpc.by_tags.id, null), var.vpc_id)
}


data "aws_subnets" "filtered" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  dynamic "filter" {
    for_each = local.subnet_tag_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "aws_subnets" "selected" {
  count = length(data.aws_subnets.filtered.ids)

  ids = data.aws_subnets.filtered.ids
}
