

variable "create_alb_ingress_iam" {

  description = "Whether to create IAM policy for ALB Ingress Controller"

  type = bool

}

variable "oidc_provider_arn" {

  description = "OIDC Provider ARN"

  type = string

}

variable "cluster_tags" {

  type = map(any)

}
