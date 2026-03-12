variable "config" {
  description = "GitHub organization webhook configuration"
  type = object({
    webhook = object({
      active = optional(bool, true)
      events = list(string)

      configuration = object({
        url           = string
        contentType   = optional(string, "json")
        secret        = optional(string)
        insecureSsl   = optional(bool, false)
      })
    })
  })

  validation {
    condition     = length(var.config.webhook.events) > 0
    error_message = "At least one event must be defined in webhook.events."
  }

  validation {
    condition = alltrue([
      for e in var.config.webhook.events : contains(["push", "pull_request", "issues", "commit_comment", "create", "delete", "fork", "gollum", "member", "public", "release", "status", "watch", "workflow_dispatch"], e)
    ])
    error_message = "Invalid event type in webhook.events."
  }
}
