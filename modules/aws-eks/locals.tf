locals {
  # Get only two of the private subnets to create the cluster
  node_groups_with_subnets = {
    for group_name, group in var.node_groups : group_name => merge(
      {
        for k, v in group : k => v
        if k != "pre_bootstrap_user_data"
      },
      {
        subnet_ids = (
          (lookup(group, "subnet_ids", null) != null)
          ? group.subnet_ids
          : local.selected_subnet_ids
        )
      },
      (
        contains(keys(group), "pre_bootstrap_user_data")
        ? {
          launch_template = merge(
            lookup(group, "launch_template", {}),
            {
              user_data = group.pre_bootstrap_user_data
            }
          )
        }
        : (
          contains(keys(group), "launch_template")
          ? {
            launch_template = group.launch_template
          }
          : {}
        )
      )
    )
  }

  # Keep module input backwards-compatible: accept list and map it by name
  fargate_profiles_map = {
    for profile in var.fargate_profiles :
    profile.name => {
      name      = profile.name
      selectors = profile.selectors
      tags      = profile.tags
    }
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

  backstage_reader_role_name_regex = "^${replace(replace(var.backstage_reader_role_name, ".", "\\."), "+", "\\+")}$"
  argocd_admin_role_name_regex     = "^${replace(replace(var.argocd_admin_role_name, ".", "\\."), "+", "\\+")}$"

  #######################################
  # Final Subnet Selection (Dynamic Logic)
  #######################################
  # Decide which subnet IDs to use (filtered or manually provided)
  selected_subnet_ids = var.subnet_tags != null && length(data.aws_subnets.filtered.ids) > 0 ? data.aws_subnets.filtered.ids : var.subnet_ids

  backstage_reader_role_arns = var.enable_backstage_reader_access_entry ? [
    for role in data.aws_iam_role.backstage_reader_candidates : role.arn
    if alltrue([for key, value in var.backstage_reader_role_tags : lookup(role.tags, key, null) == value])
  ] : []

  argocd_admin_role_arns = var.enable_argocd_admin_access_entry ? [
    for role in data.aws_iam_role.argocd_admin_candidates : role.arn
    if alltrue([for key, value in var.argocd_admin_role_tags : lookup(role.tags, key, null) == value])
  ] : []

  integration_access_entries = merge(
    var.enable_backstage_reader_access_entry ? {
      firestartr_backstage_reader = {
        principal_arn = terraform_data.backstage_reader_role_validation[0].output.role_arn
        policy_associations = {
          AmazonEKSViewPolicy = {
            policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    } : {},
    var.enable_argocd_admin_access_entry ? {
      firestartr_argocd_admin = {
        principal_arn = terraform_data.argocd_admin_role_validation[0].output.role_arn
        policy_associations = {
          AmazonEKSClusterAdminPolicy = {
            policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    } : {}
  )

  effective_access_entries = merge(var.access_entries, local.integration_access_entries)
}
