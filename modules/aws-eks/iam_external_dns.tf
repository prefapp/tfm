

/*

  IAM Role for External DNS

  This IAM Role is used by External DNS to manage Route53 records.

  If you use the External DNS chart, you must create an IAM role for External DNS to use.

  DOC: https://github.com/kubernetes-sigs/external-dns

  RESOURCES:

    - IAM Role -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
    - IAM Policy -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
    - IAM Role Policy Attachment -> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

*/
# IAM Policy for External DNS

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
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResources"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

# IAM Role for External DNS

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
  tags = var.externaldns_tags
}


# IAM Policy Attachment for External DNS

resource "aws_iam_role_policy_attachment" "external-dns-AmazonEKSClusterPolicy" {

  count = var.create_external_dns_iam ? 1 : 0

  policy_arn = aws_iam_policy.external_dns_policy[count.index].arn

  role = aws_iam_role.external-dns-Kubernetes[count.index].name

}
