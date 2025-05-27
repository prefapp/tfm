# Get only two of the private subnets to create the cluster
locals {
  node_groups_with_subnets = {
    for group_name, group in var.node_groups : group_name => merge(
      group,
      {
        subnet_ids = (
          (lookup(group, "subnet_ids", null) != null)
          ? group.subnet_ids
          : data.aws_subnets.by_ids[*].id
        )
      }
    )
  }
}


locals {
  selected_vpcs = var.vpc_id != null ? [var.vpc_id] : (
    var.vpc_tags != null ? [data.aws_vpcs.by_tag[0].id] : []
  )
}

locals {
  # Explicit subnet_ids always take priority
  explicit_subnets = coalesce(var.subnet_ids, [])

  # Subnets discovered via tags (only if no explicit IDs are given)
  discovered_subnets = length(local.explicit_subnets) == 0 && var.subnet_tags != null ? (
    data.aws_subnets.by_tags[0].ids
  ) : []

  #Final selection (fails if empty)
  selected_subnets = concat(local.explicit_subnets, local.discovered_subnets)

}

locals {
  vpc_subnets_map = { for idx, vpc_id in local.selected_vpcs :
    vpc_id => [
      for subnet_id in local.selected_subnets :
      subnet_id if contains(data.aws_subnets.by_ids[*].vpc_id, vpc_id)
    ]
  }
}
