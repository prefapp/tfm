locals {
  lifecycle_rules = (var.s3_replication_destination != null || var.s3_replication_source != null || var.s3_bucket_versioning == "Enabled") ? concat(var.lifecycle_rules, var.default_lifecycle_rules) : var.lifecycle_rules
}

check "replication_requires_enabled_versioning" {
  assert {
    condition = (
      var.s3_replication_destination == null && var.s3_replication_source == null
    ) || var.s3_bucket_versioning == "Enabled"
    error_message = "s3_bucket_versioning must be set to \"Enabled\" when s3_replication_destination or s3_replication_source is configured."
  }
}
