resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(local.lifecycle_rules) > 0 ? 1 : 0
  region = var.region
  bucket = var.create_bucket ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id

  dynamic "rule" {
    for_each = local.lifecycle_rules
    content {
      id     = rule.value.id
      status = try(rule.value.status, "Enabled")

      dynamic "filter" {
        for_each = try(rule.value.filter, null) != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix

          dynamic "and" {
            for_each = try(filter.value.and, null) != null ? [filter.value.and] : []
            content {
              prefix                   = and.value.prefix
              object_size_greater_than = and.value.object_size_greater_than
              object_size_less_than    = and.value.object_size_less_than
            }
          }
        }
      }

      dynamic "transition" {
        for_each = try(rule.value.transitions, null) != null ? rule.value.transitions : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = try(rule.value.expiration, null) != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = try(rule.value.noncurrent_version_expiration, null) != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.noncurrent_days, null)
        }

      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(rule.value.abort_incomplete_multipart_upload, null) != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }

      }

    }

  }
}