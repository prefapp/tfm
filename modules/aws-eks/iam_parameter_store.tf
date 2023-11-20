# IAM PARAMETER STORE

# Policy for parameter store
resource "aws_iam_policy" "iam_policy_parameter_store" {

  count = var.create_parameter_store_iam == true ? 1 : 0

  name = "iam_policy_parameter_store"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["ssm:GetParameter", "ssm:GetParameters"],
      "Resource" : [
        "arn:aws:ssm:${var.region}:${var.aws_account}:parameter/*",
      ]
    }]
  })
}

# Role for parameter store
resource "aws_iam_role" "iam_role_parameter_store_all" {

  count = var.create_parameter_store_iam == true ? 1 : 0

  name = "iam_role_parameter_store_all"

  description = "IAM role to access to the parameter store"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:*:*"
          }
        }
      }
    ]
  })
}

# Attach parameter store role and parameter store policy for parameter store
resource "aws_iam_role_policy_attachment" "iam_role_parameter_store_all_attachment" {

  count = var.create_parameter_store_iam == true ? 1 : 0

  role       = aws_iam_role.iam_role_parameter_store_all.name
  policy_arn = aws_iam_policy.iam_policy_parameter_store.arn
}
