variable "region" {
  type = string
}

# Comprobar si podemos sacarlo programáticamente aws_caller_identity
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
# variable "account_id" {
#   type = string
# }

variable "cluster_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_tags" {
  type = map(any)

}


variable "iam_role_arn" {

  type = string

}


# NODE GROUPS
variable "node_groups" {

  description = "Define dynamically the different k8s node groups"

  type = any

}

variable "security_groups_ids" {

  description = "Security group ids"

  type = list(string)

}


# AUTH

# Users
# variable "aws_auth_users" {

#   description = "Additional IAM users to add to the aws-auth configmap."

#   type = list(object({

#     userarn = string

#     username = string

#     groups = list(string)

#   }))

#   default = []
# }


# Roles
variable "aws_auth_roles" {

  description = "Additional IAM roles to add to the aws-auth configmap."

  type = list(object({

    rolearn = string

    username = string

    groups = list(string)

  }))

  default = []
}


# ADDONS

# Addons required by the cluster
variable "addons" {

  description = "Enables the core-dns addon"

  type = any

}


# # CLUSTER SECURITY GROUP
# variable "cluster_security_group_additional_rules" {

#   description = "Additional rules to add to the cluster security group"

#   type = any

# }


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

# # FARGATE
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


variable "aws_auth_users" {

  type = any

}
