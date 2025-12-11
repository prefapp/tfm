/*
  This Terraform script is used to define the variables required for the
  configuration of an EKS cluster. It includes variables for basic cluster
  configuration like region, cluster version, and cluster name. It also includes
  variables for more complex configurations like node groups, security group
  ids, IAM roles, and various feature flags (like enable_irsa,
  create_cluster_iam_role, etc.). Additionally, it defines variables for AWS
  auth users and roles, various IAM resources, subnet ids, VPC id, fargate
  profiles, and cluster addons. Lastly, it includes variables for cluster
  encryption config, log group retention, and cluster tags.
*/

variable "region" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "cluster_iam_role_arn" {
  type = string

  default = null
}

variable "node_groups" {
  description = "Define dynamically the different k8s node groups"

  type    = any
  default = {}
}

variable "create_cluster_iam_role" {
  description = "Create IAM role for cluster"

  type = bool

  default = true
}

variable "enable_irsa" {
  description = "Enable IRSA"

  type = bool

  default = true
}

# IAMs
variable "create_alb_ingress_iam" {
  description = "Create IAM resources for alb-ingress"

  type = bool

  default = false
}

variable "create_cloudwatch_iam" {
  description = "Create IAM resources for cloudwatch"

  type = bool

  default = false
}

variable "create_efs_driver_iam" {
  description = "Create IAM resources for efs-driver"

  type = bool

  default = false
}

variable "create_external_dns_iam" {
  description = "Create IAM resources for external-dns"

  type = bool

  default = false
}

variable "externaldns_tags" {
  type = map(any)

  default = {}
}

variable "external_dns_role_name" {
  description = "IAM role name for external-dns. Leave null to generate it with the cluster name. For backward compatibility set \"external-dns-Kubernetes\"."

  type    = string
  default = null
}

variable "create_parameter_store_iam" {
  description = "Create IAM resources for parameter-store"

  type = bool

  default = false
}

variable "alb_ingress_role_name" {
  description = "IAM role name for ALB Ingress. Leave null to generate one per cluster (composed with project/env/cluster). For backward compatibility, set a name like: k8s-<tags.project>-<tags.env>-oidc-role."
  type        = string
  default     = null
}

variable "parameter_store_role_name" {
  description = "IAM role name for Parameter Store. Leave null to generate one per cluster. For backward compatibility, use the legacy name without suffix: iam_role_parameter_store_all."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet ids"

  type    = list(string)
  default = null
}

variable "subnet_tags" {
  description = "Map of subnet tags to filter which subnets we want"

  type    = map(string)
  default = null
}

variable "vpc_tags" {
  description = "Map of VPC tags to filter which VPC we want"

  type    = map(string)
  default = null
}

variable "vpc_id" {
  description = "VPC ID"

  type    = string
  default = null
}

variable "fargate_profiles" {
  description = "Define dynamically the different fargate profiles"

  type = list(object({
    name = string
    selectors = list(object({
      namespace = string
      labels    = map(string)
    }))
    tags = map(string)
  }))

  default = []
}

variable "node_security_group_additional_rules" {
  description = "Additional rules to add to the node security group"

  type = any
}

variable "cluster_security_group_additional_rules" {
  description = "Additional rules for the cluster security group"

  type = any

  default = {}
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default is false."

  type = bool

  default = false
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default is true."

  type = bool

  default = true
}

variable "cluster_addons" {
  description = "Addons to deploy to the cluster"

  type = any

  default = {}
}

variable "create_kms_key" {
  description = "Create KMS key for cluster"

  type = bool

  default = true
}

variable "cluster_encryption_config" {
  description = "Cluster encryption config"

  type = any

  default = {}
}

variable "cluster_security_group_id" {
  type = string

  default = ""
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"

  type = number

  default = 14
}

variable "create_cluster_security_group" {
  description = "Create cluster security group"

  type = bool

  default = true
}

variable "cluster_tags" {
  description = "Tags to apply to the EKS cluster"

  type = map(string)

  default = {}
}

variable "access_entries" {
  description = "Access entries to apply to the EKS cluster"

  type = any

  default = {}
}

variable "enable_karpenter" {
  description = "Enable Karpenter provisioning"

  type = bool

  default = false
}
