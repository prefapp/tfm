# Notifications
resource "cloudamqp_notification" "this" {
  for_each = var.notifications

  instance_id = cloudamqp_instance.this.id
  type = each.value.type
  value = each.value.value
  name = each.value.name
}
