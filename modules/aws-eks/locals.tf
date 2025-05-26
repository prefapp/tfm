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
          : data.aws_subnets.by_ids[*].id
        )
      }
    )
  }
}


locals {
  selected_vpcs = var.vpc_id != null ? [data.aws_vpc.by_id[0].id] : (
    var.vpc_tags != null ? data.aws_vpcs.by_tags[0].ids : []
  )
}

locals {
  selected_subnets = var.subnet_ids != null ? var.subnet_ids : (
    var.subnet_tags != null ? flatten(data.aws_subnets.by_tags[*].ids) : []
  )
}

locals {
  vpc_subnets_map = { for idx, vpc_id in local.selected_vpcs :
    vpc_id => [
      for subnet_id in local.selected_subnets :
      subnet_id if contains(data.aws_subnet.by_ids[*].vpc_id, vpc_id)
    ]
  }
}
