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

  validation {
    condition     = length(split("/", trimspace(var.config.repository))) == 2
    error_message = "config.repository must be in the format 'owner/repo' (e.g. 'acme/my-app')."
  }

  validation {
    condition = alltrue([
      for name in concat(
        keys(var.config.actions),
        keys(var.config.codespaces),
        keys(var.config.dependabot),
      ) : can(regex("^[A-Z0-9_]+$", name))
    ])
    error_message = "All secret names must use GitHub's allowed pattern: only uppercase letters, digits, and underscores."
  }

  validation {
    condition = alltrue([
      for value in concat(
        values(var.config.actions),
        values(var.config.codespaces),
        values(var.config.dependabot),
      ) : trim(value) != "" && can(base64decode(value))
    ])
    error_message = "All encrypted secret values must be non-empty and valid base64-encoded strings."
  }

  nullable  = false
  sensitive = true
}
