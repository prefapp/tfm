# Role needed to authenticate by the workflow
output "oidc_role_arn" {
  value = aws_iam_role.gh_oidc_rol.arn
}
