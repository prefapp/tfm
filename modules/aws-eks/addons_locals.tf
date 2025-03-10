
locals {

  /*
   * Base addons that are always enabled by default
   */
  base_addons = {
    vpc-cni = {
      enabled = true
      addon_version  = null
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
      enabled = true
      addon_version  = null
      resolve_conflicts = "OVERWRITE"
    },
    coredns = {
      enabled = true
      addon_version  = null
      resolve_conflicts = "OVERWRITE"
    },
    aws-ebs-csi-driver = {
      enabled = true
      addon_version  = null
      resolve_conflicts = "OVERWRITE"
      service_account_role_arn = local.ebs_arn_role
    }
  }
  
  /*
   * mixed_addons: Combines base_addons with var.cluster_addons to produce the final result.
   * - Iterates over all unique keys from base_addons and var.cluster_addons.
   * - Merges default values with custom values.
   * - Only includes configuration_values when relevant (present in base_addons or var.cluster_addons).
   */
  mixed_addons = {
    # Iterate over a unique list of keys combining base_addons and var.cluster_addons
    # distinct(concat(...)) ensures no duplicates and includes new addons like "new_addon"
    for addon_name in distinct(concat(keys(local.base_addons), keys(var.cluster_addons))) :
    addon_name => merge(
      # Step 1: Get default values from base_addons (if the addon exists, otherwise empty map)
      lookup(local.base_addons, addon_name, {}),
      
      # Step 2: Override with values from var.cluster_addons (if the addon exists, otherwise empty map)
      lookup(var.cluster_addons, addon_name, {}),
      
      # Step 3: Conditional handling of configuration_values
      # Only include configuration_values if it exists in base_addons or var.cluster_addons
      (contains(keys(lookup(var.cluster_addons, addon_name, {})), "configuration_values") || 
       contains(keys(lookup(local.base_addons, addon_name, {})), "configuration_values")) ? {
        configuration_values = {
          # Merge the 'env' submap of configuration_values
          env = merge(
            # Default env values from base_addons
            # If base_addons has configuration_values, use its 'env', otherwise use empty map
            lookup(lookup(local.base_addons, addon_name, {}), "configuration_values", {}) != {} ? 
              lookup(lookup(local.base_addons, addon_name, {}), "configuration_values", {}).env : {},
            
            # Overridden env values from var.cluster_addons
            # If var.cluster_addons has configuration_values, use its 'env', otherwise use empty map
            lookup(lookup(var.cluster_addons, addon_name, {}), "configuration_values", {}) != {} ? 
              lookup(lookup(var.cluster_addons, addon_name, {}), "configuration_values", {}).env : {}
          )
        }
      } : {}  # If configuration_values is not present in either, do not include this attribute
    )
  }

  processed_addons = {
    for addon_name, config in local.mixed_addons : addon_name => merge(config, {
      # Si configuration_values existe, lo convertimos a JSON; si no, lo dejamos como null
      configuration_values = try(jsonencode(config.configuration_values), null)
    })
  }

  /*
    Finally, we set the cluster_addons variable to the configured_addons
    variable, and we get the addons that are not disabled
  */
  cluster_addons = { for key, value in merge(local.processed_addons) : key => value if lookup(value, "enabled", true) == true }

}
