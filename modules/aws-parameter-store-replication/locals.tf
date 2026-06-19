locals {
  # Parse destinations JSON
  destinations = try(jsondecode(var.destinations_json), {})

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

  # Flatten destinations into a list for easier iteration
  all_account_regions = flatten([
    for account_id, account_config in local.destinations : [
      for region, region_config in account_config.regions : {
        account_id  = account_id
        region      = region
        role_arn    = account_config.role_arn
        kms_key_arn = try(region_config.kms_key_arn, null)
        kms_key_id  = try(region_config.kms_key_arn, null) != null ? split("/", region_config.kms_key_arn)[length(split("/", region_config.kms_key_arn)) - 1] : null
      }
    ]
  ])

  # Tags for all resources
  common_tags = merge(
    var.tags,
    {
      Module = "aws-parameter-store-replication"
      Name   = local.lambda_name
    }
  )
}
