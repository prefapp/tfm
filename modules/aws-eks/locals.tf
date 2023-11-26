################################################################################
# Local Variables
################################################################################
locals {

  account_id = data.aws_caller_identity.current.account_id

  cluster_addons = merge(
    {},

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
