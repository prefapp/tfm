###############################################################################
# Random suffix for bucket name when creating
###############################################################################

resource "random_integer" "suffix" {
  count = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  min   = 10000
  max   = 99999
}



###############################################################################
# S3 bucket for CloudTrail (create only if not provided)
###############################################################################

resource "aws_s3_bucket" "cloudtrail" {
  count         = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  bucket        = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}-${random_integer.suffix[0].result}"
  force_destroy = false
  tags          = var.tags
}

# Baseline hardening for CloudTrail S3 bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.s3_bucket_name == "" && var.eventbridge_enabled ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

###############################################################################
# CloudTrail (create only if not provided)
###############################################################################

resource "aws_cloudtrail" "secrets_management_events" {
  count                         = var.cloudtrail_name == "" && var.eventbridge_enabled ? 1 : 0
  name                          = "${var.prefix}-secrets-management-events"
  is_multi_region_trail         = false
  include_global_service_events = false
  enable_logging                = true
  s3_bucket_name                = local.s3_bucket_id

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.tags

  # Asegura que la policy S3 esté aplicada antes de crear el CloudTrail, solo si se gestiona la policy
  depends_on = var.manage_s3_bucket_policy ? [aws_s3_bucket_policy.cloudtrail] : []

}

###############################################################################
# S3 bucket policy (manage only if requested and bucket is known)
###############################################################################


# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.eventbridge_enabled && var.manage_s3_bucket_policy && (var.s3_bucket_name != "" || length(aws_s3_bucket.cloudtrail) > 0) ? 1 : 0
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : aws_s3_bucket.cloudtrail[0].id

  lifecycle {
    precondition {
      condition     = !(var.cloudtrail_name != "" && var.cloudtrail_arn == "")
      error_message = "If cloudtrail_name is set, cloudtrail_arn must also be provided unless the module is creating the CloudTrail. This precondition prevents creating a policy with an invalid SourceArn reference."
    }
  }

  policy = (
    (var.s3_bucket_name != "" && var.existing_bucket_policy_json != null) ?
    jsonencode(merge(
      local.decoded_existing_bucket_policy,
      {
        Statement = concat(
          local.decoded_existing_bucket_policy_statements,
          [
            {
              Sid       = "AWSCloudTrailAclCheck"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
              Resource  = local.s3_bucket_arn
              Condition = merge({
                StringEquals = {
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
              }, (
                local.use_cloudtrail_arn ? {
                  ArnLike = {
                    "aws:SourceArn" = local.cloudtrail_arn
                  }
                } : {}
              ))
            },
            {
              Sid       = "AWSCloudTrailWrite"
              Effect    = "Allow"
              Principal = { Service = "cloudtrail.amazonaws.com" }
              Action    = "s3:PutObject"
              Resource  = local.s3_bucket_logs_arn
              Condition = merge({
                StringEquals = {
                  "s3:x-amz-acl"      = "bucket-owner-full-control"
                  "aws:SourceAccount" = data.aws_caller_identity.current.account_id
                }
              }, (
                local.use_cloudtrail_arn ? {
                  ArnLike = {
                    "aws:SourceArn" = local.cloudtrail_arn
                  }
                } : {}
              ))
            }
          ]
        )
      }
    ))
    : jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "AWSCloudTrailAclCheck"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action = [
            "s3:GetBucketAcl",
            "s3:GetBucketPolicy"
          ]
          Resource = local.s3_bucket_arn
          Condition = merge({
            StringEquals = {
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
          }, (
            local.use_cloudtrail_arn ? {
              ArnLike = {
                "aws:SourceArn" = local.cloudtrail_arn
              }
            } : {}
          ))
        },
        {
          Sid       = "AWSCloudTrailWrite"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action    = "s3:PutObject"
          Resource  = local.s3_bucket_logs_arn
          Condition = merge({
            StringEquals = {
              "s3:x-amz-acl"      = "bucket-owner-full-control"
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
          }, (
            var.s3_bucket_name != "" && var.cloudtrail_name != "" && var.cloudtrail_arn != "" && var.cloudtrail_name != "" && var.cloudtrail_arn != "" ? {
              ArnLike = {
                "aws:SourceArn" = local.cloudtrail_arn
              }
            } : {}
          ))
        }
      ]
    })
  )
}

