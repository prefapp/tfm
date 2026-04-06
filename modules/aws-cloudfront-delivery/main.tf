resource "random_id" "oac_suffix" {
  byte_length = 4
  # This random suffix is used to ensure the default OAC name is unique per deployment
}

locals {
  # If oac_name is not provided, generate it as "<name_prefix>-s3-oac-<random>" (truncated to 64 chars, AWS limit) to ensure uniqueness
  resolved_oac_name = var.oac_name != null ? var.oac_name : substr("${var.name_prefix}-s3-oac-${random_id.oac_suffix.hex}", 0, 64)
}
