module "s3-bucket-delivery" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.8.2"

  bucket = "${var.name_prefix}-delivery"

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
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
