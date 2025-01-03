#https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc
resource "cloudamqp_vpc" "this" {
  name   = var.vpc_name
  region = var.region
  subnet = var.subnet
  tags   = var.tags
}
