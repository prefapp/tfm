################################################################################
# IAM Policy for External DNS
################################################################################

resource "aws_iam_policy" "external_dns_policy" {

  count = var.create_external_dns_iam ? 1 : 0

  name = "external_dns_policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

################################################################################
# IAM Role for External DNS
################################################################################

resource "aws_iam_role" "external-dns-Kubernetes" {

  count = var.create_external_dns_iam ? 1 : 0

  name = "external-dns-Kubernetes"

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
          "StringLike" : {
            "${split("oidc-provider/", var.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
  tags = {
    environment = "demo"
    concern     = "Kubernetes"
  }
}

################################################################################
# IAM Policy Attachment for External DNS
################################################################################

resource "aws_iam_role_policy_attachment" "external-dns-AmazonEKSClusterPolicy" {

  count = var.create_external_dns_iam ? 1 : 0

  policy_arn = aws_iam_policy.external_dns_policy[count.index].arn

  role       = aws_iam_role.external-dns-Kubernetes[count.index].name

}
