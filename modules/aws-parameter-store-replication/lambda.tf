###############################################################################
# Lambda using the official module
###############################################################################

module "lambda_automatic_replication" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = local.lambda_automatic_function_name
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  source_path = [
    "${path.module}/src/lambda_automatic_replication",
    "${path.module}/src/common"
  ]

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = local.common_tags

  environment_variables = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON         = var.destinations_json
      ENABLE_TAG_REPLICATION    = tostring(var.enable_tag_replication)
      ADD_REGION_PREFIX_TO_NAME = tostring(var.add_region_prefix_to_name)
    }
  )

  create_role = false
  lambda_role = aws_iam_role.lambda_automatic_replication.arn
}


################################################################################
# Lambda for manual parameter replication (triggered via API or console, not EventBridge)
################################################################################
module "lambda_manual_replication" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  count = var.manual_replication_enabled ? 1 : 0

  function_name = local.lambda_manual_function_name
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  source_path = [
    "${path.module}/src/lambda_manual_replication",
    "${path.module}/src/common"
  ]

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = local.common_tags

  environment_variables = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON         = var.destinations_json
      ENABLE_TAG_REPLICATION    = tostring(var.enable_tag_replication)
      ENABLE_FULL_SYNC          = tostring(var.enable_full_sync)
      ADD_REGION_PREFIX_TO_NAME = tostring(var.add_region_prefix_to_name)
    }
  )

  create_role = false
  lambda_role = aws_iam_role.lambda_manual_replication[0].arn
}
