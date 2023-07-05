terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4"
    }

  }
}

provider "aws" {
  region = var.region
}

resource "aws_iam_openid_connect_provider" "gh_oidc_entity_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

resource "aws_iam_role_policy" "gh_oidc_policy" {
  name = "gh_oidc_policy"
  role = aws_iam_role.gh_oidc_rol.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "gh_oidc_rol" {
  name = "gh_oidc_rol"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.gh_oidc_entity_provider.arn
        }
        Condition : {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "${var.subs}",
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
