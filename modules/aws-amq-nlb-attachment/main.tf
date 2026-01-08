# Associates Amazon MQ broker ENIs to an NLB target group

variable "broker_private_ips" {
  description = "List of private IPs of the broker instances"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the NLB target group"
  type        = string
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = toset(var.broker_private_ips)
  target_group_arn = var.target_group_arn
  target_id        = each.value
  port             = 5671
}
