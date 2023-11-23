variable "create_efs_driver_iam" {

  description = "Whether to create IAM policy for EFS CSI Driver"

  type = bool

}

variable "oidc_provider_arn" {

  description = "OIDC Provider ARN"

  type = string

}
