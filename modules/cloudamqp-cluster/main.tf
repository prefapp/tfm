# https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs
provider "cloudamqp" {
  apikey = var.api_key
}

terraform {
  required_providers {
    cloudamqp = {
      source  = "cloudamqp/cloudamqp"
      version = "1.32.2"
    }
  }
}
