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
  selected_vpcs = var.vpc_id != null ? [data.aws_vpc.by_id[0].id] : (
    var.vpc_tags != null ? data.aws_vpcs.by_tag[0].ids : []
  )
}

locals {
  # Get subnets from explicit IDs if provided
  subnets_from_ids = var.subnet_ids != null ? var.subnet_ids : []

  # Get subnets from tags if no explicit IDs were provided
  subnets_from_tags = length(local.subnets_from_ids) == 0 && var.subnet_tags != null ? (data.aws_subnets.by_tags[0].ids) : []

  # Final selection (fails if neither source provided subnets)
  selected_subnets = length(local.subnets_from_ids) > 0 ? (local.subnets_from_ids) : (local.subnets_from_tags)

  # Optional validation
  validate_subnets = length(local.selected_subnets) > 0 ? true : (
    file("ERROR: No subnets could be discovered - provide either subnet_ids or subnet_tags")
  )
}

locals {
  vpc_subnets_map = { for idx, vpc_id in local.selected_vpcs :
    vpc_id => [
      for subnet_id in local.selected_subnets :
      subnet_id if contains(data.aws_subnets.by_ids[*].vpc_id, vpc_id)
    ]
  }
}
