# The checks are warnings, not errors. So the user will be able to continue with the apply.
# docs: https://developer.hashicorp.com/terraform/tutorials/configuration-language/checks
check "vpc-cni-addon-enabled" {

  assert {

    condition = !(lookup(local.cluster_addons.vpc-cni, "addon_disabled", false) == true)

    error_message = "vpc-cni is being disabled in cluster_addons"

  }

}

check "vpc-cni-addon-configuration-values-will-be-overwritten" {

  assert {

    condition = !(

      lookup(local.cluster_addons.vpc-cni, "addon_disabled", false) == false &&

      lookup(local.cluster_addons.vpc-cni, "configuration_values", null) != null &&

      jsonencode(local.base_addons.vpc-cni.configuration_values) != lookup(local.configured_addons.vpc-cni, "configuration_values", jsonencode(local.base_addons.vpc-cni.configuration_values))

    )

    error_message = "vpc-cni configuration values will be overwritten"

  }

}
