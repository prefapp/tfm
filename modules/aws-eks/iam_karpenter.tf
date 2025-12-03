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
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile"
        ],
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/karpenter-${var.cluster_name}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Karpenter-${var.cluster_name}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/karpenter-${var.cluster_name}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/Karpenter-${var.cluster_name}*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.cluster_name}*"
        ],
        "Sid" : "KarpenterIAMInstanceProfile"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource" : "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:karpenter-${var.cluster_name}",
        "Sid" : "KarpenterSQSInterruptionQueue"
      }
    ]
  })

  tags = var.tags
}

# Attach the extra policy to the Karpenter controller role
resource "aws_iam_role_policy_attachment" "karpenter_controller_extra_policy" {
  count      = var.enable_karpenter ? 1 : 0
  role       = format("%s-karpenter-role", var.cluster_name)
  policy_arn = aws_iam_policy.iam_policy_extra_karpenter[0].arn

  # Esperar a que el módulo de Karpenter cree el rol antes de adjuntar la política
  depends_on = [module.karpenter]
}