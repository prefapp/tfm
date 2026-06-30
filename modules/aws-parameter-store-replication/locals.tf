locals {
  # Parse destinations JSON (validation in variables.tf ensures it's valid)
  destinations = jsondecode(var.destinations_json)

  # Lambda naming
  naming_base = "${var.prefix}-${var.name}"

  lambda_function_name_base = "${local.naming_base}-replication"
  lambda_function_name_hash = substr(md5(local.lambda_function_name_base), 0, 8)
  lambda_function_name      = length(local.lambda_function_name_base) <= 64 ? local.lambda_function_name_base : "${substr(local.lambda_function_name_base, 0, 55)}-${local.lambda_function_name_hash}"

  lambda_role_name_base = "${local.naming_base}-replication-role"
  lambda_role_name_hash = substr(md5(local.lambda_role_name_base), 0, 8)
  lambda_role_name      = length(local.lambda_role_name_base) <= 64 ? local.lambda_role_name_base : "${substr(local.lambda_role_name_base, 0, 55)}-${local.lambda_role_name_hash}"

  eventbridge_rule_name_base = "${local.naming_base}-parameter-changes"
  eventbridge_rule_name_hash = substr(md5(local.eventbridge_rule_name_base), 0, 8)
  eventbridge_rule_name      = length(local.eventbridge_rule_name_base) <= 64 ? local.eventbridge_rule_name_base : "${substr(local.eventbridge_rule_name_base, 0, 55)}-${local.eventbridge_rule_name_hash}"

  lambda_async_failure_dlq_name_base = "${local.naming_base}-replication-failure-dlq"
  lambda_async_failure_dlq_name_hash = substr(md5(local.lambda_async_failure_dlq_name_base), 0, 8)
  lambda_async_failure_dlq_name      = length(local.lambda_async_failure_dlq_name_base) <= 80 ? local.lambda_async_failure_dlq_name_base : "${substr(local.lambda_async_failure_dlq_name_base, 0, 71)}-${local.lambda_async_failure_dlq_name_hash}"

  lambda_async_errors_alarm_name_base = "${local.naming_base}-replication-async-errors"
  lambda_async_errors_alarm_name_hash = substr(md5(local.lambda_async_errors_alarm_name_base), 0, 8)
  lambda_async_errors_alarm_name      = length(local.lambda_async_errors_alarm_name_base) <= 255 ? local.lambda_async_errors_alarm_name_base : "${substr(local.lambda_async_errors_alarm_name_base, 0, 246)}-${local.lambda_async_errors_alarm_name_hash}"

  lambda_async_dlq_alarm_name_base = "${local.naming_base}-replication-async-dlq-visible"
  lambda_async_dlq_alarm_name_hash = substr(md5(local.lambda_async_dlq_alarm_name_base), 0, 8)
  lambda_async_dlq_alarm_name      = length(local.lambda_async_dlq_alarm_name_base) <= 255 ? local.lambda_async_dlq_alarm_name_base : "${substr(local.lambda_async_dlq_alarm_name_base, 0, 246)}-${local.lambda_async_dlq_alarm_name_hash}"

  # Tags for all resources
  common_tags = merge(
    var.tags,
    {
      Module = "aws-parameter-store-replication"
      Name   = local.naming_base
    }
  )
}
