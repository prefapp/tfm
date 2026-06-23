locals {
  # Parse destinations JSON (validation in variables.tf ensures it's valid)
  destinations = jsondecode(var.destinations_json)

  # Lambda naming
  naming_base = "${var.prefix}-${var.name}"

  lambda_automatic_function_name_base = "${local.naming_base}-automatic"
  lambda_manual_function_name_base    = "${local.naming_base}-manual"
  lambda_automatic_function_name_hash = substr(md5(local.lambda_automatic_function_name_base), 0, 8)
  lambda_manual_function_name_hash    = substr(md5(local.lambda_manual_function_name_base), 0, 8)
  lambda_automatic_function_name      = length(local.lambda_automatic_function_name_base) <= 64 ? local.lambda_automatic_function_name_base : "${substr(local.lambda_automatic_function_name_base, 0, 55)}-${local.lambda_automatic_function_name_hash}"
  lambda_manual_function_name         = length(local.lambda_manual_function_name_base) <= 64 ? local.lambda_manual_function_name_base : "${substr(local.lambda_manual_function_name_base, 0, 55)}-${local.lambda_manual_function_name_hash}"
  lambda_name                    = local.lambda_automatic_function_name
  lambda_role_name_base          = "${local.naming_base}-replication-role"
  lambda_manual_role_name_base   = "${local.naming_base}-replication-manual-role"
  lambda_role_name_hash          = substr(md5(local.lambda_role_name_base), 0, 8)
  lambda_manual_role_name_hash   = substr(md5(local.lambda_manual_role_name_base), 0, 8)
  lambda_role_name               = length(local.lambda_role_name_base) <= 64 ? local.lambda_role_name_base : "${substr(local.lambda_role_name_base, 0, 55)}-${local.lambda_role_name_hash}"
  lambda_manual_role_name        = length(local.lambda_manual_role_name_base) <= 64 ? local.lambda_manual_role_name_base : "${substr(local.lambda_manual_role_name_base, 0, 55)}-${local.lambda_manual_role_name_hash}"
  eventbridge_rule_name_base     = "${local.naming_base}-parameter-changes"
  eventbridge_rule_name_hash     = substr(md5(local.eventbridge_rule_name_base), 0, 8)
  eventbridge_rule_name          = length(local.eventbridge_rule_name_base) <= 64 ? local.eventbridge_rule_name_base : "${substr(local.eventbridge_rule_name_base, 0, 55)}-${local.eventbridge_rule_name_hash}"

  # Tags for all resources
  common_tags = merge(
    var.tags,
    {
      Module = "aws-parameter-store-replication"
      Name   = local.lambda_name
    }
  )
}
