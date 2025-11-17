
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "gh_delivery_gh_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${var.name_prefix}-bucket/*"
    ]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.cloudfront-delivery.cloudfront_distribution_id}"
    ]
  }
}

resource "aws_iam_role" "gh_delivery_gh_role" {
  count = var.gh_delivery_gh_role_enable ? 1 : 0

  name = "${var.name_prefix}-gh-delivery-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          "ForAnyValue:StringLike" = {
            "token.actions.githubusercontent.com:sub" = [for repo in var.gh_delivery_gh_repositories : "repo:${repo}:*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "gh_delivery_gh_policy_attach" {
  count = var.gh_delivery_gh_role_enable ? 1 : 0

  role   = aws_iam_role.gh_delivery_gh_role[0].name
  policy = data.aws_iam_policy_document.gh_delivery_gh_policy.json
}
