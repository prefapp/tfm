# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/instance
resource "cloudamqp_instance" "this" {
  name                = var.cloudamqp_instance.name
  plan                = var.cloudamqp_instance.plan
  region              = var.cloudamqp_instance.region
  tags                = var.tags
  nodes               = var.cloudamqp_instance.nodes
  rmq_version         = var.cloudamqp_instance.rmq_version
  keep_associated_vpc = var.cloudamqp_instance.keep_associated_vpc
  no_default_alarms   = var.cloudamqp_instance.no_default_alarms
  lifecycle {
    ignore_changes = [rmq_version]
  }
}
