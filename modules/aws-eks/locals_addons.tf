
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

  base_addons = {
    vpc-cni    = {},
    kube-proxy = {},
    coredns    = {},
  }

  mixed_addons = merge(
    local.base_addons,
    var.cluster_addons
  )

  cluster_addons = { for key, value in merge(
    {
      for key, value in local.mixed_addons : key => {

        for k, v in merge(
          {
            addon_disabled = false,

            configuration_values = (key == "vpc-cni" ? jsonencode({

              env = {
                ENABLE_PREFIX_DELEGATION = "true"
                MINIMUM_IP_TARGET        = "8"
                WARM_IP_TARGET           = "4"
                WARM_PREFIX_TARGET       = "1"
              }
            }) : null)

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

  ) : key => value if value.addon_disabled != true }
}
