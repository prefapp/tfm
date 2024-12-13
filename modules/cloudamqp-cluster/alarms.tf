# Alarms
resource "cloudamqp_alarm" "this" {
  for_each = var.alarms

  instance_id = cloudamqp_instance.instance.id
  type = each.value.type
  enabled = each.value.enabled
  reminder_interval = each.value.reminder_interval
  value_threshold = each.value.value_threshold
  time_threshold = each.value.time_threshold
  recipients = [cloudamqp_notification.recipient[each.value.recipient_key].id]
}
