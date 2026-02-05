resource "aws_s3_bucket" "this" {
  bucket              = var.bucket
  region              = var.region
  object_lock_enabled = var.object_lock_enabled
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
## ACL Config
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
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
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.only_https.json
}

data "aws_iam_policy_document" "only_https" {
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
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}
# END Bucket Policy

## Bucket Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  region = var.region
  versioning_configuration {
    status = var.s3_bucket_versioning
  }
}
# END Bucket Versioning

