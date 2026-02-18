###############################################################################
# Random suffix for bucket name when creating
###############################################################################

resource "random_integer" "suffix" {
  count = var.s3_bucket_arn == "" && var.eventbridge_enabled ? 1 : 0
  min   = 10000
  max   = 99999
}



###############################################################################
# S3 bucket for CloudTrail (create only if not provided)
###############################################################################

resource "aws_s3_bucket" "cloudtrail" {
  count         = var.s3_bucket_arn == "" && var.eventbridge_enabled ? 1 : 0
  bucket        = var.s3_bucket_arn != "" ? try(regexall("^arn:aws:s3:::(.+)$", var.s3_bucket_arn)[0][0], "INVALID_S3_BUCKET_ARN") : "${var.prefix}-cloudtrail-${data.aws_caller_identity.current.account_id}-${random_integer.suffix[0].result}"
  force_destroy = false
  tags          = var.tags
}

# Baseline hardening for CloudTrail S3 bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = var.s3_bucket_arn == "" && var.eventbridge_enabled ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.s3_bucket_arn == "" && var.eventbridge_enabled ? 1 : 0
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
  count                         = var.cloudtrail_arn == "" && var.eventbridge_enabled ? 1 : 0
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

  # Ensure S3 policy is applied before creating CloudTrail (Terraform requires static list)
  depends_on = [aws_s3_bucket_policy.cloudtrail]

}

###############################################################################
# S3 bucket policy (manage only if requested and bucket is known)
###############################################################################


# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.eventbridge_enabled && var.manage_s3_bucket_policy && (var.s3_bucket_arn != "" || length(aws_s3_bucket.cloudtrail) > 0) ? 1 : 0
  bucket = var.s3_bucket_arn != "" ? try(regexall("^arn:aws:s3:::(.+)$", var.s3_bucket_arn)[0][0], "INVALID_S3_BUCKET_ARN") : aws_s3_bucket.cloudtrail[0].id

  # No precondition: only cloudtrail_arn is relevant for existing resources

  policy = var.existing_bucket_policy_json != null ? jsonencode(merge(
    jsondecode(var.existing_bucket_policy_json),
    {
      Statement = concat(
        try(jsondecode(var.existing_bucket_policy_json).Statement, []),
        [
          {
            Sid       = "AWSCloudTrailAclCheck"
            Effect    = "Allow"
            Principal = { Service = "cloudtrail.amazonaws.com" }
            Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
            Resource  = local.s3_bucket_arn
            Condition = (var.cloudtrail_arn != "" ? {
              StringEquals = {
                "aws:SourceAccount" = data.aws_caller_identity.current.account_id
              }
              ArnLike = {
                "aws:SourceArn" = var.cloudtrail_arn
              }
              } : {
              StringEquals = {
                "aws:SourceAccount" = data.aws_caller_identity.current.account_id
              }
            })
          },
          {
            Sid       = "AWSCloudTrailWrite"
            Effect    = "Allow"
            Principal = { Service = "cloudtrail.amazonaws.com" }
            Action    = "s3:PutObject"
            Resource  = local.s3_bucket_logs_arn
            Condition = (var.cloudtrail_arn != "" ? {
              StringEquals = {
                "s3:x-amz-acl"      = "bucket-owner-full-control"
                "aws:SourceAccount" = data.aws_caller_identity.current.account_id
              }
              ArnLike = {
                "aws:SourceArn" = var.cloudtrail_arn
              }
              } : {
              StringEquals = {
                "s3:x-amz-acl"      = "bucket-owner-full-control"
                "aws:SourceAccount" = data.aws_caller_identity.current.account_id
              }
            })
          }
        ]
      )
    }
    )) : jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
        Resource  = local.s3_bucket_arn
        Condition = (var.cloudtrail_arn != "" ? {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = var.cloudtrail_arn
          }
          } : {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        })
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = local.s3_bucket_logs_arn
        Condition = (var.cloudtrail_arn != "" ? {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control"
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = var.cloudtrail_arn
          }
          } : {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control"
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        })
      }
    ]
  })
}


