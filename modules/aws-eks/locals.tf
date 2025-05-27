# Get only two of the private subnets to create the cluster
locals {
  private_subnet_ids = data.aws_subnets.private_by_tag.ids
}

locals {
  node_groups_with_subnets = {
    for group_name, group in var.node_groups : group_name => merge(
      group,
      {
        subnet_ids = (
          (lookup(group, "subnet_ids", null) != null)
          ? group.subnet_ids
          : data.aws_subnets.private_by_tag.ids
        )
      }
    )
  }
}

# Convert vpc_tags into a list of filters
locals {
  vpc_tag_filters = [
    for k, v in var.vpc_tags : {
      name   = "tag:${k}"
      values = [v]
    }
  ]
}


locals {
  subnet_tag_filters = [
    for k, v in var.subnet_tags : {
      name   = "tag:${k}"
      values = [v]
    }
  ]
}
