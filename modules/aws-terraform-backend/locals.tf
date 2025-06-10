locals {
  # template without variable interpolation
  raw_template = file("${path.module}/template.yaml")

  # template with variable interpolation
  rendered_template = templatefile("${path.module}/template.yaml", {
    FirestartrAccountId = var.aws_account_id
    FirestartrRoleName  = var.aws_account_role
  })

  # Only create a S3 object if a bucket is specified
  should_upload = var.s3_bucket_cloudformation_role != ""
}
