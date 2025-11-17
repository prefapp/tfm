data "aws_iam_policy_document" "s3_policy" {
  # Attach require latest tls policy
  statement {
    sid       = "denyOutdatedTLS"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      module.s3-bucket-delivery.s3_bucket_arn,
      "${module.s3-bucket-delivery.s3_bucket_arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

  # Deny insecure transport policy
  statement {
    sid       = "denyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      module.s3-bucket-delivery.s3_bucket_arn,
      "${module.s3-bucket-delivery.s3_bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3-bucket-delivery.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cloudfront-delivery.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3-bucket-delivery.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

module "s3-bucket-delivery" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.8.2"

  bucket = "${var.name_prefix}-delivery"

  attach_policy                             = true
  policy                                    = data.aws_iam_policy_document.s3_policy.json
  # attach_deny_insecure_transport_policy = true # moved to data aws_iam_policy_document
  # attach_require_latest_tls_policy      = true # moved to data aws_iam_policy_document
  versioning = {
    status     = true
    mfa_delete = false
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name      = format("%s-delivery", var.name_prefix)
      terraform = true
    }
  )
}
