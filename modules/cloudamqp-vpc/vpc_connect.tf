#https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc_connect
resource "cloudamqp_vpc_connect" "this" {
  count = var.cloudamqp_vpc_connect == null ? 0 : 1

  instance_id            = try(var.cloudamqp_vpc_connect.instance_id, null)
  region                 = try(var.cloudamqp_vpc_connect.region, null)
  approved_subscriptions = try(var.cloudamqp_vpc_connect.approved_subscriptions, [])
  sleep                  = try(var.cloudamqp_vpc_connect.sleep, null)
  timeout                = try(var.cloudamqp_vpc_connect.timeout, null)
}

moved {
  from = cloudamqp_vpc_connect.this
  to   = cloudamqp_vpc_connect.this[0]
}
