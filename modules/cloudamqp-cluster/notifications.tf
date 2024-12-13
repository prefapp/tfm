# New Recipient
resource "cloudamqp_notification" "recipient" {
  for_each = var.recipients
  instance_id = cloudamqp_instance.instance.id

  value = each.value.value
  name = each.value.name
  type = each.value.type
}
