/*

  IAM CloudWatch

  This IAM role is used by the CloudWatch Agent to manage AWS resources on your behalf.

  If you use the fluentd chart, you must create an IAM role for the CloudWatch agent to use.

  DOC: https://docs.aws.amazon.com/eks/latest/userguide/monitoring.html

  RESOURCES:

    - IAM Role -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
    - IAM Role Policy Attachment -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

*/

locals {

  /**
   * Get the EBS ARN role
   */

  ebs_iam_role_name = "AmazonEKS_EBS_CSI_DriverRole"

  ebs_arn_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.ebs_iam_role_name}"

  ebs_addon_is_enabled = var.create_ebs_driver_iam && !lookup(local.configured_addons.aws-ebs-csi-driver, "addon_disabled", false)

}


# Role IAM EBS
resource "aws_iam_role" "ebs_driver_policy" {

  count = local.ebs_addon_is_enabled ? 1 : 0

  name = local.ebs_iam_role_name

  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",

    "Statement" : [
      {
        "Effect" : "Allow",

        "Principal" : {

          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}"

        },

        "Action" : "sts:AssumeRoleWithWebIdentity",

        "Condition" : {

          "StringLike" : {

            "${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}:aud" : "sts.amazonaws.com",

            "${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


# Attach the IAM policy to the IAM role

resource "aws_iam_role_policy_attachment" "ebs_driver_policy_attachment" {

  count = local.ebs_addon_is_enabled ? 1 : 0

  role = aws_iam_role.ebs_driver_policy[0].name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}
