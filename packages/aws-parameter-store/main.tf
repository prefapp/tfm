data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

# Policy to allow access to the EKS cluster from the EKS service account
resource "aws_iam_policy" "parameter_store" {
  name = "parameter_store_${var.env}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["ssm:GetParameter", "ssm:GetParameters"],
      "Resource" : [
        "arn:aws:ssm:${var.region}:${var.aws_account}:parameter/*"
      ]
    }]
  })
}

# Role IAM Parameter Store to access the EKS cluster from the EKS service account
resource "aws_iam_role" "parameter_store" {
  for_each = var.services
  name     = "parameter_store_service_${each.value["name"]}_${var.env}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.aws_account}:oidc-provider/${split("https://", data.aws_eks_cluster.main.identity[0].oidc[0].issuer)[1]}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${split("https://", data.aws_eks_cluster.main.identity[0].oidc[0].issuer)[1]}:sub" : "system:serviceaccount:${var.env}:${each.value["name"]}-${var.env}-sa"
          }
        }
      }
    ]
  })
}

# Attachment to link the role to the policy
resource "aws_iam_role_policy_attachment" "parameter_store" {
  for_each   = var.services
  role       = aws_iam_role.parameter_store[each.key].name
  policy_arn = aws_iam_policy.parameter_store.arn
  depends_on = [
    aws_iam_policy.parameter_store,
    aws_iam_role.parameter_store
  ]
}
