
################################################################################
# IAM Policy for CloudWatch
################################################################################

resource "aws_iam_policy" "policy_additional_cloudwatch" {

  count = var.create_cloudwatch_iam ? 1 : 0

  name = "policy_additional_cloudwatch"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutRetentionPolicy",
        ],
        "Resource" : "*"
      }
    ]
  })
}


################################################################################
# IAM Role for CloudWatch
################################################################################

resource "aws_iam_role" "iam_role_fluentd" {

  count = var.create_cloudwatch_iam ? 1 : 0

  name = "eks-pro-fluentd-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${split("oidc-provider/", var.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:kube-system:fluentd-sa"
          }
        }
      }
    ]
  })
}


################################################################################
# IAM Role Policy Attachment for CloudWatch
################################################################################

resource "aws_iam_role_policy_attachment" "iam_role_fluentd_CloudWatchAgentServerPolicy" {

  count = var.create_cloudwatch_iam ? 1 : 0

  role = aws_iam_role.iam_role_fluentd[count.index].name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

################################################################################
# IAM Role Policy Attachment for CloudWatch
################################################################################

resource "aws_iam_role_policy_attachment" "iam_role_fluentd_CloudWatchAdditionalPolicy" {

  count = var.create_cloudwatch_iam ? 1 : 0

  role = aws_iam_role.iam_role_fluentd[count.index].name

  policy_arn = aws_iam_policy.policy_additional_cloudwatch[count.index].arn

}
