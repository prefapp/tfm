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

  type = any
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

variable "create_parameter_store_iam" {
  description = "Create IAM resources for parameter-store"

  type = bool

  default = false
}

variable "subnet_ids" {
  description = "Subnet ids"

  type = list(string)
}


variable "vpc_id" {
  description = "VPC ID"

  type = string
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

  type = map(object({
    description                   = string
    protocol                      = string
    source_cluster_security_group = optional(bool)
    from_port                     = number
    to_port                       = number
    type                          = string
    cidr_blocks                   = optional(list(string))
    ipv6_cidr_blocks              = optional(list(string))
    self                          = optional(bool)
  }))
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

variable "manage_aws_auth_configmap" {
  description = "Whether to manage aws-auth configmap"

  type = bool

  default = false
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