locals {
  # Validate that if s3_replication_destination is configured, versioning must be enabled
  validate_replication_versioning = (
    var.s3_replication_destination == null || var.s3_bucket_versioning == "Enabled"
  ) ? true : file("ERROR: When configuring s3_replication_destination, s3_bucket_versioning must be set to \"Enabled\".")

  lifecycle_rules = (var.s3_replication_destination != null || var.s3_bucket_versioning == "Enabled") ? concat(var.lifecycle_rules, var.default_lifecycle_rules) : var.lifecycle_rules
}
