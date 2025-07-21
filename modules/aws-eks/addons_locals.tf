
locals {

  /*
   * Base addons that are always enabled by default
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
   * - Iterates over all unique addon names from base_addons and var.cluster_addons.
   * - Merges default values (from base_addons) with user-defined overrides (from var.cluster_addons).
   * - Passes configuration_values as-is (freeform object), avoiding assumptions about internal structure.
   */
  mixed_addons = {
    for addon_name in distinct(concat(keys(local.base_addons), keys(var.cluster_addons))) :
    addon_name => merge(
      # Step 1: Get default values from base_addons (or empty map if not defined)
      lookup(local.base_addons, addon_name, {}),

      # Step 2: Override with values from var.cluster_addons (or empty map if not defined)
      lookup(var.cluster_addons, addon_name, {}),

      # Step 3: If configuration_values exists in either base or override, include it as-is
      contains(keys(lookup(var.cluster_addons, addon_name, {})), "configuration_values") ?
      {
        configuration_values = lookup(var.cluster_addons[addon_name], "configuration_values", {})
      } :
      contains(keys(lookup(local.base_addons, addon_name, {})), "configuration_values") ?
      {
        configuration_values = lookup(local.base_addons[addon_name], "configuration_values", {})
      } :
      {}
    )
  }

  processed_addons = {
    for addon_name, config in local.mixed_addons : addon_name => merge(config, {
      # If configuration_values ​​exists, we convert it to JSON; if not, we leave it as null
      configuration_values = try(jsonencode(config.configuration_values), null)
    })
  }

  /*
    Finally, we set the cluster_addons variable to the configured_addons
    variable, and we get the addons that are not disabled
  */
  cluster_addons = { for key, value in merge(local.processed_addons) : key => value if lookup(value, "enabled", true) == true }

}
