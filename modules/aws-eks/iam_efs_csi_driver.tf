# # IAM EFS CSI DRIVER

# # Policy for EKS_EFS_CSI_DriverRole
# resource "aws_iam_policy" "iam_policy_EFS_CSI_DriverRole" {

#   count = var.create_efs_driver_iam == true ? 1 : 0

#   name = "iam_policy_EFS_CSI_DriverRole"

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "elasticfilesystem:DescribeAccessPoints",
#           "elasticfilesystem:DescribeFileSystems",
#           "elasticfilesystem:DescribeMountTargets",
#           "ec2:DescribeAvailabilityZones"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "elasticfilesystem:CreateAccessPoint"
#         ],
#         "Resource" : "*",
#         "Condition" : {
#           "StringLike" : {
#             "aws:RequestTag/efs.csi.aws.com/cluster" : "true"
#           }
#         }
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "elasticfilesystem:TagResource"
#         ],
#         "Resource" : "*",
#         "Condition" : {
#           "StringLike" : {
#             "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
#           }
#         }
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : "elasticfilesystem:DeleteAccessPoint",
#         "Resource" : "*",
#         "Condition" : {
#           "StringEquals" : {
#             "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
#           }
#         }
#       }
#     ]
#   })
# }

# # Role for EKS_EFS_CSI_DriverRole
# resource "aws_iam_role" "iam_role_EKS_EFS_CSI_DriverRole" {

#   count = var.create_efs_driver_iam == true ? 1 : 0

#   name = "iam_role_EKS_EFS_CSI_DriverRole"

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
#           "StringLike" : {
#             "${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:*:*"
#           }
#         }
#       }
#     ]
#   })
# }

# # Attach EKS_EFS_CSI_DriverRole Role Policy to EKS_EFS_CSI_DriverRole Policies
# resource "aws_iam_role_policy_attachment" "iam_role_EKS_EFS_CSI_DriverRole_attachment" {

#   count = var.create_efs_driver_iam == true ? 1 : 0

#   role       = aws_iam_role.iam_role_EKS_EFS_CSI_DriverRole.name
#   policy_arn = aws_iam_policy.iam_policy_EFS_CSI_DriverRole.arn
# }
