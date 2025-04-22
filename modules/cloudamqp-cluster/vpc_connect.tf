#https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc_connect
resource "cloudamqp_vpc_connect" "this" {
  instance_id            = var.cloudamqp_vpc_connect.instance_id
  region                 = var.cloudamqp_instance.region
  approved_subscriptions = var.cloudamqp_vpc_connect.approved_subscriptions
  timeout                = var.cloudamqp_vpc_connect.timeout
}
