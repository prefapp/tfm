variable "config" {
  description = <<-EOT
    Complete configuration object for this module (single repository only).

    • repository          = GitHub repo in 'owner/repo' format (required)
    • actions / codespaces / dependabot = map of secret_name => encrypted_value
    • encrypted_value must be pre-encrypted with libsodium using the repo's public key.
  EOT

  type = object({
    repository = string

    actions = optional(map(string), {})
    codespaces = optional(map(string), {})
    dependabot = optional(map(string), {})
  })

  validation {
    condition = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", var.config.repository))
    error_message = "config.repository must be in 'owner/repo' format."
  }

  nullable = false
}
