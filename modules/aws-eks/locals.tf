# Get only two of the private subnets to create the cluster
locals {
  private_subnet_ids = data.aws_subnets.private_by_tag.ids
}

locals {
  vpc_id = coalesce(try(data.aws_vpc.by_tag[0].id, null), var.vpc_id)
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
