# IMPORT EXAMPLES

# import {

#   to = module.eks_prefapp.module.eks.aws_eks_cluster.this[0]

#   id = local.values.cluster_name

# }

# import {

#   to = module.eks_prefapp.aws_iam_policy.external_dns_policy[0]

#   id = "arn:aws:iam::${module.eks_prefapp.account_id}:policy/external_dns_policy"

# }

# import {

#   to = module.eks_prefapp.aws_iam_policy.iam_policy_parameter_store[0]

#   id =  "arn:aws:iam::${module.eks_prefapp.account_id}:policy/iam_policy_parameter_store"

# }

# import {

#   to = module.eks_prefapp.aws_iam_role.external-dns-Kubernetes[0]

#   id = "external-dns-Kubernetes"

# }

# import {

#   to = module.eks_prefapp.aws_iam_policy.iam_policy_alb[0]

#   id = "arn:aws:iam::${module.eks_prefapp.account_id}:policy/k8s-${local.values.tags.project}-${local.values.tags.env}-alb-policy"

# }

# import {

#   to = module.eks_prefapp.aws_iam_role.iam_role_oidc[0]

#   id = "k8s-prefapp-pro-oidc-role"

# }


# import {

#   to = module.eks_prefapp.aws_iam_policy.policy_additional_cloudwatch[0]

#   id = "arn:aws:iam::${module.eks_prefapp.account_id}:policy/policy_additional_cloudwatch"

# }

# import {

#   to = module.eks_prefapp.aws_iam_role_policy_attachment.iam_role_parameter_store_all_attachment[0]

#   id = "iam_role_parameter_store_all/arn:aws:iam::${module.eks_prefapp.account_id}:policy/iam_policy_parameter_store"
# }

# import {

#   to = module.eks_prefapp.aws_iam_role.iam_role_parameter_store_all[0]

#   id = "iam_role_parameter_store_all"

# }

# import {

#   to = module.eks_prefapp.aws_iam_role.iam_role_fluentd[0]

#   id = "eks-pro-fluentd-role"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_cloudwatch_log_group.this[0]

#   id = "/aws/eks/k8s-prefapp-pro/cluster"
# }

# import {

#   to = module.eks_prefapp.module.eks.aws_eks_addon.this["coredns"]

#   id = "${local.values.cluster_name}:coredns"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_eks_addon.this["vpc-cni"]

#   id = "${local.values.cluster_name}:vpc-cni"

# }

# import {

#   to = module.eks_prefapp.aws_iam_role_policy_attachment.external-dns-AmazonEKSClusterPolicy[0]

#   id = "external-dns-Kubernetes/arn:aws:iam::${module.eks_prefapp.account_id}:policy/external_dns_policy"
# }

# import {

#   to = module.eks_prefapp.aws_iam_role_policy_attachment.iam_role_fluentd_CloudWatchAdditionalPolicy[0]

#   id = "eks-pro-fluentd-role/arn:aws:iam::${module.eks_prefapp.account_id}:policy/policy_additional_cloudwatch"

# }

# import {

#   to = module.eks_prefapp.aws_iam_role_policy_attachment.iam_role_fluentd_CloudWatchAgentServerPolicy[0]

#   id = "eks-pro-fluentd-role/arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# import {

#   to = module.eks_prefapp.aws_iam_role_policy_attachment.iam_role_scm_attachment[0]

#   id = "k8s-prefapp-pro-oidc-role/arn:aws:iam::${module.eks_prefapp.account_id}:policy/k8s-prefapp-pro-alb-policy"
# }

# import {

#   to = module.eks_prefapp.module.eks.aws_security_group.node[0]

#   id = "XXXXXXXXXXXXXXXXXXXX"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_iam_openid_connect_provider.oidc_provider[0]

#   id = "arn:aws:iam::${module.eks_prefapp.account_id}:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/F9E0412AB59E2CA1AA09267BCB3DEBB1"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["egress_all"]

#   id = "XXXXXXXXXXXXXXXXXXXX_egress_all_0_0_0.0.0.0/0_::/0"

# }


# import {
#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_alb_node_ports"]

#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_tcp_30000_32400_0.0.0.0/0"
# }

# # import {

# #   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_allow_access_from_control_plane"]

# #   id = "XXXXXXXXXXXXXXXXXXXX_ingress_tcp_9443_9443_XXXXXXXXXXXXXXXXXXXX"
# # }



# import {

#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_cluster_443"]

#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_tcp_443_443_XXXXXXXXXXXXXXXXXXXX"

# }

# import {
#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]
#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_tcp_10250_10250_XXXXXXXXXXXXXXXXXXXX"
# }

# import {

#   to = module.eks_prefapp.module.eks.module.eks_managed_node_group["worker"].aws_eks_node_group.this[0]

#   id = "${local.values.cluster_name}:worker-XXXXXXXXXXXXXXXXXXXX"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"]

#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_tcp_9443_9443_XXXXXXXXXXXXXXXXXXXX"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_self_all"]

#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_all_0_0_XXXXXXXXXXXXXXXXXXXX"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]

#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_tcp_53_53_XXXXXXXXXXXXXXXXXXXX"

# }


# import {

#   to = module.eks_prefapp.module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]

#   id = "XXXXXXXXXXXXXXXXXXXX_ingress_udp_53_53_XXXXXXXXXXXXXXXXXXXX"
# }


# import {

#   to = module.eks_prefapp.module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]

#   id = "${local.values.cluster_name}:aws-ebs-csi-driver"

# }

# import {

#   to = module.eks_prefapp.module.eks.aws_eks_addon.this["kube-proxy"]

#   id = "${local.values.cluster_name}:kube-proxy"

# }


# ####


# # import {

# #   to = 

# #   id = ""

# # }
