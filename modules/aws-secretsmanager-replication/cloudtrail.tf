data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "this" {
  name                          = "${var.prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs[0].id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  count  = var.cloudtrail_bucket_name == null ? 1 : 0
  bucket = var.cloudtrail_bucket_name == null ? "${var.prefix}-cloudtrail-logs" : var.cloudtrail_bucket_name
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  count  = var.cloudtrail_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs[0].id}"
      },
      {
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs[0].id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

locals {
  cloudtrail_bucket = var.cloudtrail_bucket_name != null ? var.cloudtrail_bucket_name : aws_s3_bucket.cloudtrail_logs[0].id
}
