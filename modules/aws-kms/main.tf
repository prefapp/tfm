resource "aws_kms_key" "this" {
  region                  = var.aws_region
  description             = var.description
  multi_region            = var.multiregion
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.kms_default_statement.json
  tags                    = var.alias != null ? merge({ "alias" = var.alias }, var.tags) : var.tags

  lifecycle {
    precondition {
      condition     = length(var.aws_regions_replica) == 0 || var.multiregion == true
      error_message = "KMS replica keys can only be created for multi-region keys. Set multiregion = true when using aws_regions_replica."
    }
  }
}

resource "aws_kms_alias" "this" {
  count         = var.alias != null ? 1 : 0
  region        = var.aws_region
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}

# Replica configuration

resource "aws_kms_replica_key" "replica" {
  for_each                = toset(var.aws_regions_replica)
  region                  = each.key
  description             = "${var.description} - Replica in ${each.key}"
  deletion_window_in_days = var.deletion_window_in_days
  primary_key_arn         = aws_kms_key.this.arn
  policy                  = data.aws_iam_policy_document.kms_default_statement.json

  tags = var.alias != null ? merge({ "alias" = var.alias }, var.tags) : var.tags

}

resource "aws_kms_alias" "this_replica" {
  for_each      = var.alias != null ? toset(var.aws_regions_replica) : []
  region        = each.key
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_replica_key.replica[each.key].arn
}
