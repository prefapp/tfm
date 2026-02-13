
resource "aws_s3_bucket_replication_configuration" "origin_to_destination" {
  count      = var.s3_replication_destination != null ? 1 : 0
  depends_on = [aws_s3_bucket_versioning.this]
  region     = var.region
  role       = aws_iam_role.replication[0].arn
  bucket     = var.create_bucket ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id

  rule {
    id = "origin-to-destination"

    status = "Enabled"

    delete_marker_replication {
      status = try(var.s3_replication_destination.filter.and.tags, null) == null ? "Enabled" : "Disabled"
    }
    source_selection_criteria {
      replica_modifications {
        status = "Enabled"
      }
    }

    dynamic "destination" {
      for_each = var.s3_replication_destination != null ? [var.s3_replication_destination] : []
      content {
        account       = var.s3_replication_destination.account
        bucket        = var.s3_replication_destination.bucket_arn
        storage_class = var.s3_replication_destination.storage_class
        access_control_translation {
          owner = "Destination"
        }
      }
    }


    dynamic "filter" {
      for_each = (var.s3_replication_destination.filter != null && var.s3_replication_destination.filter != {}) ? [var.s3_replication_destination.filter] : []
      content {
        prefix = filter.value.prefix

        dynamic "and" {
          for_each = filter.value.and != null ? [filter.value.and] : []
          content {
            prefix = try(and.value.prefix, null)
            tags   = try(and.value.tags, null)
          }

        }

      }
    }

    dynamic "filter" {
      for_each = try(var.s3_replication_destination.filter, null) != null ? [] : [1]
      content {

      }
    }
  }
}

## Policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  count = var.s3_replication_destination != null ? 1 : 0
  name  = substr("${var.bucket}${var.s3_replication_role_suffix}", 0, 64) # AWS IAM role names have a maximum length of 64 characters; truncate to IAM's limit
  # region             = var.region
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold",
      "s3:ListBucket",
    ]
    resources = var.create_bucket ? [
      "${try(aws_s3_bucket.this[0].arn, "")}",
      "${try(aws_s3_bucket.this[0].arn, "")}/*",
      "${try(var.s3_replication_destination.bucket_arn, "")}",
      "${try(var.s3_replication_destination.bucket_arn, "")}/*",
      ] : [
      "${try(data.aws_s3_bucket.this[0].arn, "")}",
      "${try(data.aws_s3_bucket.this[0].arn, "")}/*",
      "${try(var.s3_replication_destination.bucket_arn, "")}",
      "${try(var.s3_replication_destination.bucket_arn, "")}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = var.create_bucket ? [
      "${try(aws_s3_bucket.this[0].arn, "")}/*",
      "${try(var.s3_replication_destination.bucket_arn, "")}/*",
      ] : [
      "${try(data.aws_s3_bucket.this[0].arn, "")}/*",
      "${try(var.s3_replication_destination.bucket_arn, "")}/*",
    ]
  }

}

resource "aws_iam_policy" "replication" {
  count = var.s3_replication_destination != null ? 1 : 0
  name  = substr("${var.bucket}${var.s3_replication_role_suffix}", 0, 38) # AWS IAM policy names have a maximum length of 64 characters, and we need to account for the random suffix added by Terraform

  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  count      = var.s3_replication_destination != null ? 1 : 0
  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

### Creating rule for destination bucket


data "aws_iam_policy_document" "destination_replication_s3_policy" {
  count = var.s3_replication_destination != null ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [try(aws_iam_role.replication[0].arn, "")]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]

    resources = ["${try(var.s3_replication_destination.bucket_arn, "")}/*"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [try(aws_iam_role.replication[0].arn, "")]
    }

    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [try(var.s3_replication_destination.bucket_arn, "")]
  }
}