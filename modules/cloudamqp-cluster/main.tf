# https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs
provider "cloudamqp" {
  apikey = var.api_key
}

terraform {
  required_providers {
    cloudamqp = {
      source  = "cloudamqp/cloudamqp"
      version = "1.32.1"
    }
  }
}

# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.1/docs/resources/instance
resource "cloudamqp_instance" "this" {
  name              = var.cloudamqp_instance.name
  plan              = var.cloudamqp_instance.plan
  region            = var.cloudamqp_instance.region
  tags              = var.cloudamqp_instance.tags
  nodes             = var.cloudamqp_instance.nodes
  rmq_version       = var.cloudamqp_instance.rmq_version
  no_default_alarms = true
}
