resource "aws_s3_bucket" "this" {
  count               = var.create_bucket ? 1 : 0
  bucket              = var.bucket
  region              = var.region
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}
## ACL Config
resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.this[0].id
  region                  = var.region
  block_public_acls       = var.block_public_acls == null ? var.bucket_public_access : var.block_public_acls
  block_public_policy     = var.block_public_policy == null ? var.bucket_public_access : var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls == null ? var.bucket_public_access : var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets == null ? var.bucket_public_access : var.restrict_public_buckets
}
# END ACL config

## Bucket Policy to enforce HTTPS only
resource "aws_s3_bucket_policy" "this" {

  region = var.region
  bucket = var.create_bucket ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id
  policy = var.s3_replication_source != null ? data.aws_iam_policy_document.source_replication_s3_policy_with_https_policy[0].json : data.aws_iam_policy_document.only_https.json
  # policy = data.aws_iam_policy_document.only_https.json
}

data "aws_iam_policy_document" "only_https" {
  source_policy_documents = var.extra_bucket_iam_policies_json
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*",
    ]

    effect = "Deny"
    resources = var.create_bucket ? [
      aws_s3_bucket.this[0].arn,
      "${aws_s3_bucket.this[0].arn}/*",
      ] : [
      data.aws_s3_bucket.this[0].arn,
      "${data.aws_s3_bucket.this[0].arn}/*",
    ]
  }
}




data "aws_iam_policy_document" "source_replication_s3_policy" {
  count = var.s3_replication_source != null ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [try(var.s3_replication_source.role_arn, "")]
    }
    sid = "Set-permissions-for-objects"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]

    resources = var.create_bucket ? ["${try(aws_s3_bucket.this[0].arn, "")}/*"] : ["${try(data.aws_s3_bucket.this[0].arn, "")}/*"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [try(var.s3_replication_source.role_arn, "")]
    }

    sid = "Set-permissions-on-bucket"
    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = var.create_bucket ? [try(aws_s3_bucket.this[0].arn, "")] : [try(data.aws_s3_bucket.this[0].arn, "")]
  }
}


data "aws_iam_policy_document" "source_replication_s3_policy_with_https_policy" {
  count = var.s3_replication_source != null ? 1 : 0
  source_policy_documents = [
    data.aws_iam_policy_document.only_https.json,
    data.aws_iam_policy_document.source_replication_s3_policy[0].json
  ]
}
# END Bucket Policy

## Bucket Versioning
resource "aws_s3_bucket_versioning" "this" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  region = var.region
  versioning_configuration {
    status = var.s3_bucket_versioning
  }

}
# END Bucket Versioning
