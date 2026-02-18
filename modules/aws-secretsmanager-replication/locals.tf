###############################################################################
# Locals (safe for count = 0)
###############################################################################

locals {
  decoded_existing_bucket_policy            = var.existing_bucket_policy_json != null ? jsondecode(var.existing_bucket_policy_json) : null
  decoded_existing_bucket_policy_statements = local.decoded_existing_bucket_policy != null ? try(local.decoded_existing_bucket_policy.Statement, []) : []

  kms_key_arns = flatten([
    for dest in local.parsed_destinations : [
      for region_name, region_cfg in try(dest.regions, {}) : region_cfg.kms_key_arn
    ]
  ])

  using_existing_cloudtrail = var.cloudtrail_arn != ""
  using_existing_s3_bucket  = var.s3_bucket_arn != ""

  cloudtrail_arn = var.cloudtrail_arn != "" ? var.cloudtrail_arn : (
    length(aws_cloudtrail.secrets_management_events) > 0 ? aws_cloudtrail.secrets_management_events[0].arn : ""
  )

  s3_bucket_id       = local.using_existing_s3_bucket ? regex("^arn:aws:s3:::(.+)$", var.s3_bucket_arn)[0] : (length(aws_s3_bucket.cloudtrail) > 0 ? aws_s3_bucket.cloudtrail[0].id : null)
  s3_bucket_arn      = local.using_existing_s3_bucket ? var.s3_bucket_arn : (length(aws_s3_bucket.cloudtrail) > 0 ? aws_s3_bucket.cloudtrail[0].arn : null)
  s3_bucket_logs_arn = local.using_existing_s3_bucket ? "${var.s3_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" : (length(aws_s3_bucket.cloudtrail) > 0 ? "${aws_s3_bucket.cloudtrail[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*" : null)
  # has_existing_bucket is only defined once above


  # Pass DESTINATIONS_JSON and enable_tag_replication as environment variables to the Lambda
  # Note: Terraform-provided values override any conflicting keys in var.environment_variables
  environment = merge(
    var.environment_variables,
    {
      DESTINATIONS_JSON      = var.destinations_json
      ENABLE_TAG_REPLICATION = tostring(var.enable_tag_replication)
    }
  )

  parsed_destinations = try(jsondecode(var.destinations_json), {})

}
