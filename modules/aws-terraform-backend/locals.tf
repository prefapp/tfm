locals {
  rendered_template = templatefile("${path.module}/template.yaml", {
    FirestartrAccountId   = var.aws_account_id
    FirestartrAccountRole = var.aws_account_role
  })
}
