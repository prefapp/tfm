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

locals {
  cloudtrail_bucket = var.cloudtrail_bucket_name != null ? var.cloudtrail_bucket_name : aws_s3_bucket.cloudtrail_logs[0].id
}
