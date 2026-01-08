
resource "aws_lb_target_group_attachment" "this" {
  for_each = toset(var.broker_private_ips)
  target_group_arn = var.target_group_arn
  target_id        = each.value
  port             = 5671
}
