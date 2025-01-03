#https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc_connect
resource "vpc_connect" "this" {
  instance_id            = var.instance_id
  region                 = var.region
  approved_subscriptions = var.approved_subscriptions
  sleep                  = var.sleep
  timeout                = var.timeout
}
