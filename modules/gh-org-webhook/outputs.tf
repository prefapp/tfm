output "webhook_id" {
  description = "ID of the created organization webhook"
  value       = github_organization_webhook.this.id
}

output "webhook_url" {
  description = "URL of the webhook"
  value       = github_organization_webhook.this.configuration[0].url
}

output "active" {
  description = "Whether the webhook is active"
  value       = github_organization_webhook.this.active
}

output "events" {
  description = "Events the webhook is subscribed to"
  value       = github_organization_webhook.this.events
}
