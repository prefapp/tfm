resource "github_organization_webhook" "this" {
  active = var.config.webhook.active
  events = var.config.webhook.events

  configuration {
    url           = var.config.webhook.configuration.url
    content_type  = var.config.webhook.configuration.contentType
    secret        = var.config.webhook.configuration.secret
    insecure_ssl  = var.config.webhook.configuration.insecureSsl
  }
}
