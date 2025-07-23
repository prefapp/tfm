locals {

  /*
   * base_addons: Default EKS addons always enabled by default.
   * These values can be overridden by user-defined cluster_addons.
   */
  base_addons = {
    vpc-cni = {
      enabled           = true
      addon_version     = null
      resolve_conflicts = "OVERWRITE"
      configuration_values = {
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          MINIMUM_IP_TARGET        = "8"
          WARM_IP_TARGET           = "4"
          WARM_PREFIX_TARGET       = "1"
        }
      },
    },
    kube-proxy = {
      enabled           = true
      addon_version     = null
      resolve_conflicts = "OVERWRITE"
    },
    coredns = {
      enabled           = true
      addon_version     = null
      resolve_conflicts = "OVERWRITE"
    },
    aws-ebs-csi-driver = {
      enabled                  = true
      addon_version            = null
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = local.ebs_arn_role
    }
  }

  /*
   * mixed_addons: Combines base_addons with var.cluster_addons to produce the final result.
   *
   * - Iterates over all unique addon names from base_addons and cluster_addons.
   * - Merges default values from base_addons with user-defined overrides from cluster_addons.
   * - Merges configuration_values separately to avoid assumptions about structure.
   */
  mixed_addons = {
    for addon_name in distinct(concat(keys(local.base_addons), keys(var.cluster_addons))) :
    addon_name => merge(
      # Base values
      lookup(local.base_addons, addon_name, {}),
      # User override
      lookup(var.cluster_addons, addon_name, {}),
      # Merged configuration_values (only if not empty)
      {
        configuration_values = (
          length(keys(merge(
            lookup(lookup(local.base_addons, addon_name, {}), "configuration_values", {}),
            lookup(lookup(var.cluster_addons, addon_name, {}), "configuration_values", {})
          ))) > 0
          ? merge(
            lookup(lookup(local.base_addons, addon_name, {}), "configuration_values", {}),
            lookup(lookup(var.cluster_addons, addon_name, {}), "configuration_values", {})
          )
          : null
        )
      }
    )
  }

  /*
   * processed_addons:
   * - Converts the merged configuration_values into a JSON string (as required by some AWS APIs).
   * - If configuration_values is null or empty, it remains null.
   */
  processed_addons = {
    for addon_name, config in local.mixed_addons : addon_name => merge(config, {
      configuration_values = try(length(config.configuration_values) > 0, false) ? jsonencode(config.configuration_values) : null
    })
  }

  /*
   * cluster_addons:
   * - Final list of addons that will be deployed.
   * - Filters out any addons that are explicitly disabled.
   */
  cluster_addons = {
    for key, value in local.processed_addons : key => value
    if lookup(value, "enabled", true) == true
  }
}
