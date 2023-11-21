# IAM EXTERNAL DNS

# Policy for external DNS
resource "aws_iam_policy" "external_dns_policy" {

  count = var.create_external_dns_iam ? 1 : 0

  name = "external_dns_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

# Role for external dns
resource "aws_iam_role" "external-dns-Kubernetes" {

  count = var.create_external_dns_iam ? 1 : 0

  name = "external-dns-Kubernetes"

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
            "${split("oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub" : "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

# Attach external-dns-Kubernetes role and external_dns_policy for external dns
resource "aws_iam_role_policy_attachment" "external-dns-AmazonEKSClusterPolicy" {

  count = var.create_external_dns_iam ? 1 : 0

  policy_arn = aws_iam_policy.external_dns_policy[count.index].arn

  role       = aws_iam_role.external-dns-Kubernetes[count.index].name

}
