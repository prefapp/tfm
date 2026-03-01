terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "config" {
  description = <<EOT
GitHub repository secrets configuration as a single complex object.

IMPORTANT:
- encryptedValue must be ALREADY encrypted with libsodium using the target repository's public key.
- Terraform does NOT encrypt anything — it only passes the pre-encrypted value.
EOT

  type = object({
    actions = optional(map(object({
      secretName     = string
      repository     = string
      encryptedValue = string
    })), {})

    codespaces = optional(map(object({
      secretName     = string
      repository     = string
      encryptedValue = string
    })), {})

    dependabot = optional(map(object({
      secretName     = string
      repository     = string
      encryptedValue = string
    })), {})
  })

  validation {
    condition     = length(var.config.actions) + length(var.config.codespaces) + length(var.config.dependabot) > 0
    error_message = "At least one secret must be defined in actions, codespaces or dependabot."
  }

  validation {
    condition = alltrue([
      for k, v in var.config.actions : length(trimspace(v.secretName)) > 0 && length(trimspace(v.repository)) > 0
    ])
    error_message = "Every action secret must have non-empty secretName and repository."
  }

  validation {
    condition = alltrue([
      for k, v in var.config.codespaces : length(trimspace(v.secretName)) > 0 && length(trimspace(v.repository)) > 0
    ])
    error_message = "Every codespaces secret must have non-empty secretName and repository."
  }

  validation {
    condition = alltrue([
      for k, v in var.config.dependabot : length(trimspace(v.secretName)) > 0 && length(trimspace(v.repository)) > 0
    ])
    error_message = "Every dependabot secret must have non-empty secretName and repository."
  }
}
