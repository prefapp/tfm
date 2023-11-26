# # Check if vpc-cni addon is enabled

# check "vpc-cni-addon-enabled" {

#   assert {

#     condition = can(var.cluster_addons.vpc-cni)

#     error_message = "vpc-cni addon is required"

#   }

# }

# # Check if vpc-cni addon ENABLE_PREFIX_DELEGATION is set to true or false

# check "vpc-cni-addon-enable-prefix-delegation" {

#   assert {

#     condition = (

#       lookup(var.cluster_addons.vpc-cni.configuration_values.env, "ENABLE_PREFIX_DELEGATION", null) == null

#       ||

#       lookup(var.cluster_addons.vpc-cni.configuration_values.env, "ENABLE_PREFIX_DELEGATION", null) == "true"

#       ||

#       lookup(var.cluster_addons.vpc-cni.configuration_values.env, "ENABLE_PREFIX_DELEGATION", null) == "false"

#     )

#     error_message = <<-CHECK_ERROR

#       INVALID VALUE: "${var.cluster_addons.vpc-cni.configuration_values.env.ENABLE_PREFIX_DELEGATION}" IN ENABLE_PREFIX_DELEGATION  in vpc-cni ADDON

#       VALID VALUES: "true", "false" (with quotes, not boolean values)

#     CHECK_ERROR

#   }

# }

# # Check if vpc-cni addon WARM_PREFIX_TARGET is set to a valid value

# check "vpc-cni-addon-warm-prefix-target" {

#   assert {

#     condition = (

#       (
#         lookup(var.cluster_addons.vpc-cni.configuration_values.env, "WARM_PREFIX_TARGET", null) != null ?

#         can(regex("^([1-9]|[1-9][0-9]|[1-9][0-9][0-9])$", var.cluster_addons.vpc-cni.configuration_values.env.WARM_PREFIX_TARGET))

#         : true

#       )
#     )

#     error_message = <<-CHECK_ERROR

#       INVALID VALUE: "${var.cluster_addons.vpc-cni.configuration_values.env.WARM_PREFIX_TARGET}" IN WARM_PREFIX_TARGET  in vpc-cni ADDON

#       VALID VALUES: "1"-"999" (with quotes, not boolean values)

#     CHECK_ERROR

#   }

# }

# # Check if vpc-cni addon MINIMUM_IP_TARGET is set to a valid value

# check "vpc-cni-addon-minimum-ip-target" {

#   assert {

#     condition = (

#       lookup(var.cluster_addons.vpc-cni.configuration_values.env, "MINIMUM_IP_TARGET", null) == null

#       ||

#       can(regex("^([1-9]|[1-9][0-9]|[1-9][0-9][0-9])$", var.cluster_addons.vpc-cni.configuration_values.env.MINIMUM_IP_TARGET))

#     )

#     error_message = <<-CHECK_ERROR

#       INVALID VALUE: "${var.cluster_addons.vpc-cni.configuration_values.env.MINIMUM_IP_TARGET}" IN MINIMUM_IP_TARGET  in vpc-cni ADDON

#       VALID VALUES: "1"-"999" (with quotes, not boolean values)

#     CHECK_ERROR

#   }

# }

# # Check if vpc-cni addon WARM_IP_TARGET is set to a valid value

# check "vpc-cni-addon-warm-ip-target" {

#   assert {

#     condition = (

#       lookup(var.cluster_addons.vpc-cni.configuration_values.env, "WARM_IP_TARGET", null) == null

#       ||

#       can(regex("^([1-9]|[1-9][0-9]|[1-9][0-9][0-9])$", var.cluster_addons.vpc-cni.configuration_values.env.WARM_IP_TARGET))

#     )

#     error_message = <<-CHECK_ERROR

#       INVALID VALUE: "${var.cluster_addons.vpc-cni.configuration_values.env.WARM_IP_TARGET}" IN WARM_IP_TARGET  in vpc-cni ADDON

#       VALID VALUES: "1"-"999" (with quotes, not boolean values)

#     CHECK_ERROR

#   }

# }
