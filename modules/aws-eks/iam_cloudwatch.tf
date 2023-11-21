# # IAM CLOUDWATCH AGENT

# # Policy for cloudwatch
# resource "aws_iam_policy" "policy_additional_cloudwatch" {

#   count = var.create_cloudwatch_iam == true ? 1 : 0

#   name = "policy_additional_cloudwatch"

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "logs:PutRetentionPolicy",
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }

# # Role for FluentD
# resource "aws_iam_role" "iam_role_fluentd" {

#   count = var.create_cloudwatch_iam == true ? 1 : 0

#   name = "eks-pro-fluentd-role"

#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Federated" : "${module.eks.oidc_provider_arn}"
#         },
#         "Action" : "sts:AssumeRoleWithWebIdentity",
#         "Condition" : {
#           "StringEquals" : {
#             "${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:kube-system:fluentd-sa"
#           }
#         }
#       }
#     ]
#   })
# }

# # Attach Role Policy CloudWatchAgentServerPolicy in FluenD role
# resource "aws_iam_role_policy_attachment" "iam_role_fluentd_CloudWatchAgentServerPolicy" {

#   count = var.create_cloudwatch_iam == true ? 1 : 0

#   role       = aws_iam_role.iam_role_fluentd.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# # Attach Role Policy iam_role_Policy in FluenD role
# resource "aws_iam_role_policy_attachment" "iam_role_fluentd_CloudWatchAdditionalPolicy" {

#   count = var.create_cloudwatch_iam == true ? 1 : 0

#   role       = aws_iam_role.iam_role_fluentd.name
#   policy_arn = aws_iam_policy.policy_additional_cloudwatch.arn
# }
