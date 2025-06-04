locals {
  rendered_template = templatefile("${path.module}/template.yaml", {
    BackendAccountId   = var.aws_account_id
    BackendAccountRole = var.aws_account_role
  })
}
