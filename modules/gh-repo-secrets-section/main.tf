# ─────────────────────────────────────────────────────────────
# Fetch repository info (validates existence + gives canonical name)
# ─────────────────────────────────────────────────────────────
data "github_repository" "this" {
  full_name = var.config.repository
}

# ─────────────────────────────────────────────────────────────
# GitHub Actions Secrets
# ─────────────────────────────────────────────────────────────
resource "github_actions_secret" "this" {
  for_each = var.config.actions

  repository      = data.github_repository.this.name
  secret_name     = each.key
  encrypted_value = each.value

  lifecycle {
    ignore_changes = [encrypted_value]
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
  encrypted_value = each.value

  lifecycle {
    ignore_changes = [encrypted_value]
  }
}
