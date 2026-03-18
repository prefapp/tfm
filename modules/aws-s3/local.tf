locals {
  lifecycle_rules = (var.s3_replication_destination != null || var.s3_bucket_versioning == "Enabled") ? concat(var.lifecycle_rules, var.default_lifecycle_rules) : var.lifecycle_rules
}