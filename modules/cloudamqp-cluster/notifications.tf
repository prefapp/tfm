# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/notification
resource "cloudamqp_notification" "this" {
  for_each    = var.recipients
  instance_id = cloudamqp_instance.this.id

  value = each.value.value
  name  = each.value.name
  type  = each.value.type
}

