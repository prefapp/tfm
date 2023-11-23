variable "create_parameter_store_iam" {

  description = "Whether to create IAM policy for Parameter Store"

  type = bool

}


variable "region" {

  description = "AWS region"

  type = string

}


variable "oidc_provider_arn" {

  description = "OIDC Provider ARN"

  type = string

}


variable "account_id" {

  description = "AWS account ID"

  type = string
  
}
