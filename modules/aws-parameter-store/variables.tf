variable "region" {
  default     = "eu-west-1"
  description = "AWS region"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "aws_account" {
  description = "AWS Account ID"
  type        = string
}

variable "services" {
  type = map(object({
    name = string
  }))

  default = {}

}

variable "parameters" {

}

variable "env" {
  description = "Environment"
  type        = string
}
