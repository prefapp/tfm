###############################################################################
# Unified Lambda for parameter replication
# Handles both EventBridge-driven and manual invocation modes
###############################################################################

module "lambda_replication" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = local.lambda_function_name
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory
  tags        = local.common_tags

  environment_variables = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON            = var.destinations_json
      ENABLE_TAG_REPLICATION       = tostring(var.enable_tag_replication)
      ENABLE_FULL_SYNC             = tostring(var.enable_full_sync)
      ASSUME_ROLE_DURATION_SECONDS = tostring(var.assume_role_duration_seconds)
      ADD_REGION_PREFIX_TO_NAME    = tostring(var.add_region_prefix_to_name)
    }
  )

  create_role = false
  create_package = false
  local_existing_package = data.archive_file.lambda.output_path
  lambda_role = aws_iam_role.lambda_replication.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/dist/lambda.zip"
}
