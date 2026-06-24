variable "config" {
  description = <<-EOT
    Complete configuration object for this module (single repository only).

    • repository             = GitHub repo in 'owner/repo' format (required)
    • actions / codespaces / dependabot = map of secret_name => pre-encrypted secret value
    • values must be pre-encrypted with libsodium using the matching secret type public key.
    • actions_sha256 / codespaces_sha256 / dependabot_sha256 = optional map of secret_name => SHA-256 hex digest of the plaintext value.
      When provided, the module uses `terraform_data` + `replace_triggered_by` to detect
      real plaintext changes and update the secret. Without these, the module preserves
      the current lifecycle behavior (no automatic updates on ciphertext change).
  EOT

  type = object({
    repository = string

    actions    = optional(map(string), {})
    codespaces = optional(map(string), {})
    dependabot = optional(map(string), {})

    actions_sha256    = optional(map(string), {})
    codespaces_sha256 = optional(map(string), {})
    dependabot_sha256 = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", trimspace(var.config.repository)))
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
      ) : can(regex("^[A-Za-z0-9_]+$", name))
    ])
    error_message = "All secret names must contain only letters, digits, and underscores."
  }

  validation {
    condition = alltrue([
      for value in concat(
        values(var.config.actions),
        values(var.config.codespaces),
        values(var.config.dependabot),
      ) : trimspace(value) != ""
    ])
    error_message = "All encrypted secret values must be non-empty."
  }

  validation {
    condition = alltrue([
      for key in keys(var.config.actions_sha256) : contains(keys(var.config.actions), key)
    ])
    error_message = "All keys in config.actions_sha256 must exist in config.actions."
  }

  validation {
    condition = alltrue([
      for key in keys(var.config.codespaces_sha256) : contains(keys(var.config.codespaces), key)
    ])
    error_message = "All keys in config.codespaces_sha256 must exist in config.codespaces."
  }

  validation {
    condition = alltrue([
      for key in keys(var.config.dependabot_sha256) : contains(keys(var.config.dependabot), key)
    ])
    error_message = "All keys in config.dependabot_sha256 must exist in config.dependabot."
  }

  validation {
    condition = alltrue([
      for v in concat(
        values(var.config.actions_sha256),
        values(var.config.codespaces_sha256),
        values(var.config.dependabot_sha256),
      ) : can(regex("^[a-f0-9]{64}$", v))
    ])
    error_message = "All SHA-256 values must be lowercase 64-char hex digests."
  }

  nullable = false
}
