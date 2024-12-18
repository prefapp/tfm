# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.1/docs/resources/alarm
resource "cloudamqp_alarm" "this" {
  for_each = var.alarms

  type              = each.value.type
  instance_id       = cloudamqp_instance.this.id
  enabled           = each.value.enabled
  reminder_interval = each.value.reminder_interval
  value_threshold   = each.value.value_threshold
  time_threshold    = each.value.time_threshold
  recipients        = [cloudamqp_notification.this[each.value.recipient_key].id]
}
