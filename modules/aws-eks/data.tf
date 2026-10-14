/*
    This data source is used to get the current caller identity in order to
    get the account ID.

    DOC: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
*/
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_roles" "backstage_reader_candidates" {
  count      = var.enable_backstage_reader_access_entry ? 1 : 0
  name_regex = "^FirestartrBackstageReader$"
}

data "aws_iam_role" "backstage_reader_candidates" {
  for_each = var.enable_backstage_reader_access_entry ? toset(data.aws_iam_roles.backstage_reader_candidates[0].names) : toset([])
  name     = each.value
}

data "aws_iam_roles" "argocd_admin_candidates" {
  count      = var.enable_argocd_admin_access_entry ? 1 : 0
  name_regex = "^FirestartrArgoCDAdmin$"
}

data "aws_iam_role" "argocd_admin_candidates" {
  for_each = var.enable_argocd_admin_access_entry ? toset(data.aws_iam_roles.argocd_admin_candidates[0].names) : toset([])
  name     = each.value
}

#######################################
# VPC Lookup
#######################################

data "aws_vpc" "by_tags" {
  count = var.vpc_tags != null ? 1 : 0
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
  id = coalesce(try(data.aws_vpc.by_tags[0].id, null), var.vpc_id)
}


#######################################
# Subnet Lookup
#######################################

data "aws_subnets" "filtered" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
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
