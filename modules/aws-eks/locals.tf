################################################################################
# Local Variables
################################################################################
locals {

  account_id = data.aws_caller_identity.current.account_id

  addon_vpc-cni = merge({

    resolve_conflicts = "OVERWRITE"

    configuration_values = {

      env = {

        WARM_PREFIX_TARGET = "1"

        ENABLE_PREFIX_DELEGATION = "true"

        MINIMUM_IP_TARGET = "8"

        WARM_IP_TARGET = "4"

      }

    }
    },


    lookup(var.cluster_addons["vpc-cni"], null) != null ?

    var.cluster_addons["vpc-cni"]

    :

    {}

  )

  cluster_addons = merge({

    coredns = {
      resolve_conflicts = "OVERWRITE"
    }

    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }

    vpc-cni = local.addon_vpc-cni

    },

    var.cluster_addons,

    {
      for key, value in var.cluster_addons : key => {

        for k, v in merge(

          {},

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
}
