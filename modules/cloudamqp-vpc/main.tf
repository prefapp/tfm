# https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    cloudamqp = {
      source  = "cloudamqp/cloudamqp"
      version = "1.32.2"
    }
  }
}
