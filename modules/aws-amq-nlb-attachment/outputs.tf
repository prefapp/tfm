output "attachment_ids" {
  description = "IDs of the target group attachments"
  value       = [for a in aws_lb_target_group_attachment.this : a.id]
}
