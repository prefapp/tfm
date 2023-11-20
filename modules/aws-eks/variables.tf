variable "region" {
  type = string
}

variable "account_id" {
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

variable "node_groups" {

  description = "Define dynamically the different k8s node groups"

  type = list(object({

    name = string

    instance_types = list(string)

    desired_capacity = number

    min_size = number

    max_size = number

    k8s_labels = map(string)

    additional_tags = map(string)

    pre_bootstrap_user_data = string

  }))
}


# AUTH
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


# ADDONS
# Addons required by the cluster
variable "addon_vpc_cni" {

  description = "Enables the VPC CNI addon"

  type = object({

    version = string

    configuration_values = map(any)

  })

}

variable "addon_kube_proxy" {

  description = "Enables the kube-proxy addon"

  type = object({

    version = string

    configuration_values = map(any)

  })

}

variable "addon_core_dns" {

  description = "Enables the core-dns addon"

  type = object({

    version = string

    configuration_values = map(any)

  })

}

# Addons optional
variable "extra_addons" {

  description = "Enables the extra addons"

  type = list(object({

    name = string

    version = string

    configuration_values = map(any)

  }))

  default = []

}


# CLUSTER SECURITY GROUP
variable "cluster_security_group_additional_rules" {

  description = "Additional rules to add to the cluster security group"

  type = any

}


# FARGATE
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
