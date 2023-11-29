
locals {

  /*
  ##################################
  # LOCAL VARIABLES FOR THE ADDONS #
  ##################################

  > What are local variables for the addons?

    - The local addons variables allows to set the configuration_values
      for the addons without having to set the whole configuration_values map

  > How does it work?

    - The local variables for the addons are merged with the base_addons variable
      and then merged with the cluster_addons variable.

  > Can I disable an addon?

    - Yes, you can disable an addon by setting addon_disabled to true

       · Example in your .tfvars:

        cluster_addons = {
          vpc-cni = {
            addon_disabled = true
          }
        }

  > Can I set the addon version?

    - Yes, you can set the addon version by setting addon_version

       · Example in your .tfvars:

        cluster_addons = {
          vpc-cni = {
            addon_version = "v1.7.5-eksbuild.1"
          }
        }

  > Can I set the addon configuration_values?

    - Yes, you can set the addon configuration_values, it will overwrite the default values

       · Example in your .tfvars:

        cluster_addons = {
          vpc-cni = {
            configuration_values = {
              env = {
                ENABLE_PREFIX_DELEGATION = "true"
                MINIMUM_IP_TARGET        = "20"
              }
            }
          }
        }
*/

  /*
    First, we get the addons properties that are not null
  */
  cluster_addons_without_null = {

    for key, value in var.cluster_addons : key => {

      for k, v in value : k => v if v != null

    }
  }

  /**
   * Base addons that are always enabled by default
   */
  base_addons = {
    vpc-cni = {
      addon_disabled = false
      addon_version  = lookup(local.cluster_addons_without_null.vpc-cni, "addon_version", null)
      configuration_values = lookup(local.cluster_addons_without_null.vpc-cni, "configuration_values", {
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          MINIMUM_IP_TARGET        = "8"
          WARM_IP_TARGET           = "4"
          WARM_PREFIX_TARGET       = "1"
        }
      }),
    },
    kube-proxy = {
      addon_disabled = false
      addon_version  = lookup(local.cluster_addons_without_null.kube-proxy, "addon_version", null)
    },
    coredns = {
      addon_disabled = false
      addon_version  = lookup(local.cluster_addons_without_null.coredns, "addon_version", null)
    },
    aws-ebs-csi-driver = {
      addon_disabled           = false
      addon_version            = lookup(local.cluster_addons_without_null.aws-ebs-csi-driver, "addon_version", null)
      service_account_role_arn = local.ebs_arn_role
    }
  }

  mixed_addons = merge(local.cluster_addons_without_null, local.base_addons)

  /*
    Then, we merge the mixed_addons with the local variables for the addons
    that the user has set in the .tfvars file
  */
  configured_addons = merge(
    {
      for key, value in local.mixed_addons : key => {

        for k, v in merge(

          lookup(value, "configuration_values", null) != null ?

          { configuration_values = jsonencode(lookup(value, "configuration_values", null)) } : {}
          ,
          {
            addon_disabled           = value.addon_disabled,
            addon_version            = value.addon_version,
            resolve_conflicts        = lookup(value, "resolve_conflicts", null),
            service_account_role_arn = lookup(local.base_addons[key], "service_account_role_arn", null)
          },
          /**
           * Remove null properties from the configuration_values.
           */
      ) : k => v if v != null }
    }

  )

  /*
    Finally, we set the cluster_addons variable to the configured_addons
    variable, and we get the addons that are not disabled
  */
  cluster_addons = { for key, value in merge(local.configured_addons) : key => value if lookup(value, "addon_disabled", false) == false }

}
