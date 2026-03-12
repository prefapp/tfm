resource "aws_iam_policy" "iam_policy_extra_karpenter" {
  count       = var.enable_karpenter ? 1 : 0
  name_prefix = format("%s-karpenter-extra", var.cluster_name)

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:RunInstances",
          "ec2:DeleteLaunchTemplate"
        ],
        "Resource" : "*",
        "Sid" : "Karpenter"

      },
      {
        "Action" : "ec2:TerminateInstances",
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/karpenter.sh/provisioner-name" : "*"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "ConditionalEC2Termination"
      }
    ]
  })

  tags = var.tags
}