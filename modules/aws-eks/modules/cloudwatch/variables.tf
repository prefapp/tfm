variable "create_cloudwatch_iam" {

    description = "Whether to create IAM policy for ALB Ingress Controller"

    type = bool

}


variable "oidc_provider_arn" {

    description = "OIDC Provider ARN"

    type = string

}

