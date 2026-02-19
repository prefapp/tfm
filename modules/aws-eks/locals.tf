locals {
  # Adaptar fargate_profiles de lista a mapa para el módulo oficial
  fargate_profiles_map = {
    for profile in var.fargate_profiles :
    profile.name => {
      name      = profile.name
      selectors = profile.selectors
      tags      = profile.tags
    }
  }
  # Adapt node_groups for EKS v21.x compatibility (retrocompatible)
  node_groups_with_subnets = {
    for group_name, group in var.node_groups : group_name => merge(
      {
        # Si el usuario pasa pre_bootstrap_user_data, lo movemos a launch_template.user_data
        launch_template = (
          contains(keys(group), "pre_bootstrap_user_data") ? merge(
            lookup(group, "launch_template", {}),
            {
              user_data = group.pre_bootstrap_user_data
            }
          ) : (
            lookup(group, "launch_template", null)
          )
        )
      },
      # Copiamos el resto de campos, pero quitamos pre_bootstrap_user_data y launch_template antiguos
      { for k, v in group : k => v if !contains(["pre_bootstrap_user_data", "launch_template"], k) },
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
