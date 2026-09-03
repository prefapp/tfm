# aws-eks

Owns an EKS cluster, its node groups and Fargate profiles, and the opt-in IAM roles that cluster add-ons need.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**node group**:
A managed group of worker nodes declared in `node_groups`. Distinct from a *Fargate profile*, which runs pods with no nodes at all.

**IRSA**:
IAM Roles for Service Accounts — the OIDC trust that lets a Kubernetes service account assume an AWS role. Enabled by `enable_irsa`; every `create_*_iam` role below depends on it.

**IAM bundle**:
One of the opt-in role sets (`create_alb_ingress_iam`, `create_external_dns_iam`, `create_cloudwatch_iam`, `create_efs_driver_iam`, `create_parameter_store_iam`, Karpenter). Each is a role plus policy for one cluster add-on, and each is off by default.

**access entry**:
An entry in `access_entries` granting a principal access to the cluster API. This is the EKS access-entry API, not the legacy `aws-auth` ConfigMap.
_Avoid_: aws-auth mapping

**cluster addon**:
An AWS-managed add-on declared in `cluster_addons` (CoreDNS, kube-proxy, VPC CNI, EBS CSI…). Managed by the cluster, not installed as a Helm release.

**discovery tags**:
`vpc_tags` and `subnet_tags` — used to look the network up by tag when `vpc_id` / `subnet_ids` are not given.
