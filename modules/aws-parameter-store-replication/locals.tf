locals {
  # Parse destinations JSON (validation in variables.tf ensures it's valid)
  destinations = jsondecode(var.destinations_json)

  # Lambda naming
  lambda_automatic_function_name = "${var.prefix}-${var.name}-automatic"
  lambda_manual_function_name    = "${var.prefix}-${var.name}-manual"
  lambda_name                    = local.lambda_automatic_function_name
  lambda_manual_name             = local.lambda_manual_function_name
  lambda_role_name               = "${var.prefix}-${var.name}-replication-role"
  lambda_manual_role_name        = "${var.prefix}-${var.name}-replication-manual-role"
  lambda_policy_name             = "${var.prefix}-${var.name}-replication-policy"
  lambda_manual_policy_name      = "${var.prefix}-${var.name}-replication-manual-policy"
  eventbridge_rule_name          = "${var.prefix}-${var.name}-parameter-changes"

  # Tags for all resources
  common_tags = merge(
    var.tags,
    {
      Module = "aws-parameter-store-replication"
      Name   = local.lambda_name
    }
  )
}
