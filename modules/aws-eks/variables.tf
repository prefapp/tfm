variable "region" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_tags" {
  type = map(any)

}


variable "cluster_iam_role_arn" {

  type = string

}


variable "node_groups" {

  description = "Define dynamically the different k8s node groups"

  type = any

}

variable "security_groups_ids" {

  description = "Security group ids"

  type = list(string)

}

variable "create_cluster_iam_role" {

  description = "Create IAM role for cluster"

  type = bool

  default = false

}

variable "enable_irsa" {

  description = "Enable IRSA"

  type = bool

  default = false

}

variable "aws_auth_users" {

  description = "Additional IAM users to add to the aws-auth configmap."

  type = list(object({

    userarn = string

    username = string

    groups = list(string)

  }))

  default = []
}


variable "aws_auth_roles" {

  description = "Additional IAM roles to add to the aws-auth configmap."

  type = list(object({

    rolearn = string

    username = string

    groups = list(string)

  }))

  default = []
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

variable "create_ebs_driver_iam" {

  description = "Create IAM resources for ebs-driver"

  type = bool

  default = true
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

      labels = map(string)

    }))

    tags = map(string)

  }))

  default = []

}


variable "node_security_group_additional_rules" {

  description = "Additional rules to add to the node security group"

  type = map(object({

    description = string

    protocol = string

    source_cluster_security_group = optional(bool)

    from_port = number

    to_port = number

    type = string

    cidr_blocks = optional(list(string))

    ipv6_cidr_blocks = optional(list(string))

    self = optional(bool)

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

  # type = any
  type = map(object({

    addon_version = optional(string)

    addon_disabled = optional(bool)

    resolve_conflicts = optional(string)

    configuration_values = optional(object({

      env = optional(map(string))

    }))

    service_account_role_arn = optional(string)

  }))

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
