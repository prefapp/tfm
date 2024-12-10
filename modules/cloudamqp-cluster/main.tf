# Configure the CloudAMQP Provider
provider "cloudamqp" {
  apikey          = "your-api-key"
}

terraform {
  required_providers {
    cloudamqp = {
      source = "cloudamqp/cloudamqp"
      version = "1.32.1"
    }
  }
}

# Create a new cloudamqp instance
resource "cloudamqp_instance" "this" {
  name          = var.instance_name
  plan          = var.instance_plan
  region        = var.instance_region
  tags          = var.instance_tags
  nodes         = var.instance_nodes
}
