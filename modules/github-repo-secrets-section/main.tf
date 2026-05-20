# ─────────────────────────────────────────────────────────────
# Fetch repository info (validates existence + gives canonical name)
# ─────────────────────────────────────────────────────────────
data "github_repository" "this" {
  full_name = var.config.repository
}

data "github_actions_public_key" "this" {
  count = length(var.config.actions) > 0 ? 1 : 0

  repository = data.github_repository.this.name
}

data "github_dependabot_public_key" "this" {
  count = length(var.config.dependabot) > 0 ? 1 : 0

  repository = data.github_repository.this.name
}

# ─────────────────────────────────────────────────────────────
# GitHub Actions Secrets
# ─────────────────────────────────────────────────────────────
resource "github_actions_secret" "this" {
  for_each = var.config.actions

  repository      = data.github_repository.this.name
  secret_name     = each.key
  key_id          = one(data.github_actions_public_key.this[*].key_id)
  value_encrypted = each.value

  lifecycle {
    ignore_changes = [key_id, value_encrypted]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Codespaces Secrets
# ─────────────────────────────────────────────────────────────
resource "github_codespaces_secret" "this" {
  for_each = var.config.codespaces

  repository      = data.github_repository.this.name
  secret_name     = each.key
  encrypted_value = each.value

  lifecycle {
    ignore_changes = [encrypted_value]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Dependabot Secrets
# ─────────────────────────────────────────────────────────────
resource "github_dependabot_secret" "this" {
  for_each = var.config.dependabot

  repository      = data.github_repository.this.name
  secret_name     = each.key
  key_id          = one(data.github_dependabot_public_key.this[*].key_id)
  value_encrypted = each.value

  lifecycle {
    ignore_changes = [key_id, value_encrypted]
  }
}
