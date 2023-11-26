
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

locals {

  /**
   * Base addons that are always enabled by default
   */
  base_addons = {
    vpc-cni    = {},
    kube-proxy = {},
    coredns    = {},
  }

  /**
   * Configuration values for the vpc-cni addon
   */
  vcp-cni_configuration_values = {
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      MINIMUM_IP_TARGET        = "8"
      WARM_IP_TARGET           = "4"
      WARM_PREFIX_TARGET       = "1"
    }
  }

  /*
    First, we merge the base_addons with the cluster_addons variable
    that the user has set in the .tfvars file
  */
  mixed_addons = merge(
    local.base_addons,
    var.cluster_addons
  )

  /*
    Then, we merge the mixed_addons with the local variables for the addons
    that the user has set in the .tfvars file
  */
  configured_addons = merge(
    {
      for key, value in local.mixed_addons : key => {

        for k, v in merge(

          /*
            We set the default values for the addons
          */
          {

            addon_disabled = false,

            /*
              In case the addon is vpc-cni, we set the configuration_values
              to the local.vcp-cni_configuration_values variable
            */
            configuration_values = (key == "vpc-cni" ? jsonencode(local.vcp-cni_configuration_values) : null)

            resolve_conflicts = "OVERWRITE"

          },

          value,

          lookup(value, "configuration_values", null) != null ?

          {
            configuration_values = jsonencode(value.configuration_values)
          }

          :

          {

          }

      ) : k => v if v != null }
    }

  )

  /*
    Finally, we set the cluster_addons variable to the configured_addons
    variable, and we get the addons that are not disabled
  */
  cluster_addons = { for key, value in merge(local.configured_addons) : key => value if value.addon_disabled == false }
}
