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
  Single VPC ID from the filtered list
*/
data "aws_vpc" "selected" {
  id = coalesce(try(data.aws_vpc.by_tag[0].id, null), var.vpc_id)
}

/*
  Get private subents in the VPC by tag
*/
data "aws_subnets" "private_by_tag" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:eks-enabled"
    values = ["1"] # assume that the private subnets are tagged with Type=private
  }
}
