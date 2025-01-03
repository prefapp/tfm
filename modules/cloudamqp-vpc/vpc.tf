#https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc
resource "cloudamqp_vpc" "this" {
  name   = var.cloudamqp_vpc.name
  region = var.cloudamqp_vpc.region
  subnet = var.cloudamqp_vpc.subnet
  tags   = var.cloudamqp_vpc.tags
}
