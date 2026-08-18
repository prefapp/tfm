variable "config" {
  description = <<-EOT
    Complete configuration object for this module (single GitHub organization).

    • org = GitHub organization name (required)
    • actions / codespaces / dependabot = map of secret_name => secret object with:
        - value: pre-encrypted secret value (libsodium ciphertext)
        - visibility: "all", "private", or "selected" (default: "all")
        - selected_repositories: list of "owner/repo" strings (default: [])
    • values must be pre-encrypted with libsodium using the matching secret type public key.
    • actions_sha256 / codespaces_sha256 / dependabot_sha256 = optional map of secret_name => SHA-256 hex digest of the plaintext value.
      When provided, the module uses `terraform_data` + `replace_triggered_by` to detect
      real plaintext changes and update the secret. Without these, the module preserves
      the current lifecycle behavior (no automatic updates on ciphertext change).
  EOT

  type = object({
    org = string

    actions = optional(map(object({
      value                 = string
      visibility            = optional(string, "all")
      selected_repositories = optional(list(string), [])
    })), {})

    codespaces = optional(map(object({
      value                 = string
      visibility            = optional(string, "all")
      selected_repositories = optional(list(string), [])
    })), {})

    dependabot = optional(map(object({
      value                 = string
      visibility            = optional(string, "all")
      selected_repositories = optional(list(string), [])
    })), {})

    actions_sha256    = optional(map(string), {})
    codespaces_sha256 = optional(map(string), {})
    dependabot_sha256 = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", trimspace(var.config.org)))
    error_message = "config.org must be a non-empty string containing only letters, digits, and hyphens."
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
        [for s in values(var.config.actions) : s.value],
        [for s in values(var.config.codespaces) : s.value],
        [for s in values(var.config.dependabot) : s.value],
      ) : trimspace(value) != ""
    ])
    error_message = "All encrypted secret values must be non-empty."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.actions) :
      contains(["all", "private", "selected"], secret.visibility)
    ])
    error_message = "All Actions secret visibilities must be one of: all, private, selected."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.codespaces) :
      contains(["all", "private", "selected"], secret.visibility)
    ])
    error_message = "All Codespaces secret visibilities must be one of: all, private, selected."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.dependabot) :
      contains(["all", "private", "selected"], secret.visibility)
    ])
    error_message = "All Dependabot secret visibilities must be one of: all, private, selected."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.actions) :
      secret.visibility != "selected" || length(secret.selected_repositories) > 0
    ])
    error_message = "Actions secrets with visibility=selected must have at least one selected_repositories entry."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.codespaces) :
      secret.visibility != "selected" || length(secret.selected_repositories) > 0
    ])
    error_message = "Codespaces secrets with visibility=selected must have at least one selected_repositories entry."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.dependabot) :
      secret.visibility != "selected" || length(secret.selected_repositories) > 0
    ])
    error_message = "Dependabot secrets with visibility=selected must have at least one selected_repositories entry."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.actions) :
      alltrue([
        for repo in secret.selected_repositories : can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", repo))
      ])
    ])
    error_message = "All Actions selected_repositories must be in 'owner/repo' format."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.codespaces) :
      alltrue([
        for repo in secret.selected_repositories : can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", repo))
      ])
    ])
    error_message = "All Codespaces selected_repositories must be in 'owner/repo' format."
  }

  validation {
    condition = alltrue([
      for secret in values(var.config.dependabot) :
      alltrue([
        for repo in secret.selected_repositories : can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", repo))
      ])
    ])
    error_message = "All Dependabot selected_repositories must be in 'owner/repo' format."
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
