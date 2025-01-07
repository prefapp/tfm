# https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/alarm
resource "cloudamqp_alarm" "this" {
  for_each = var.alarms

  type              = each.value.type
  instance_id       = cloudamqp_instance.this.id
  enabled           = each.value.enabled
  reminder_interval = each.value.reminder_interval
  value_threshold   = each.value.value_threshold
  time_threshold    = each.value.time_threshold
  recipients        = [
    for key in each.value.recipient_key : cloudamqp_notification.this[key].id
  ]
  message_type      = each.value.message_type
  queue_regex       = each.value.queue_regex
  vhost_regex       = each.value.vhost_regex
  depends_on = [
    cloudamqp_notification.this
  ]
}
