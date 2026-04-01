variable "config" {
  description = "GitHub organization webhook configuration"
  type = object({
    webhook = object({
      active = optional(bool, true)
      events = list(string)

      configuration = object({
        url         = string
        contentType = optional(string, "json")
        secret      = optional(string)
        insecureSsl = optional(bool, false)
      })
    })
  })

  validation {
    condition     = length(var.config.webhook.events) > 0
    error_message = "At least one event must be defined in webhook.events."
  }

  validation {
    condition = alltrue([
      for e in var.config.webhook.events : length(trim(e)) > 0
    ])
    error_message = "Each webhook event must be a non-empty string."
  }
}
