variable "broker_private_ips" {
  description = "List of private IPs of the broker instances"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the NLB target group"
  type        = string
}
