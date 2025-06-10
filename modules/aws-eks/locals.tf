locals {
  # Get only two of the private subnets to create the cluster
  node_groups_with_subnets = {
    for group_name, group in var.node_groups : group_name => merge(
      group,
      {
        subnet_ids = (
          (lookup(group, "subnet_ids", null) != null)
          ? group.subnet_ids
          : local.selected_subnet_ids
        )
      }
    )
  }

  vpc_tag_filters = var.vpc_tags != null ? [
    for k, v in var.vpc_tags : {
      name   = "tag:${k}"
      values = [v]
    }
  ] : []

  subnet_tag_filters = var.subnet_tags != null ? [
    for k, v in var.subnet_tags : {
      name   = "tag:${k}"
      values = [v]
    }
  ] : []

  #######################################
  # Final Subnet Selection (Dynamic Logic)
  #######################################
  # Decide which subnet IDs to use (filtered or manually provided)
  selected_subnet_ids = var.subnet_tags != null && length(data.aws_subnets.filtered.ids) > 0 ? data.aws_subnets.filtered.ids : var.subnet_ids
}
