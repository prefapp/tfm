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
# Secret update triggers (deterministic SHA-256 of plaintext)
# When sha256 is provided, a change triggers replacement.
# When absent, the input defaults to each.key (stable → no trigger).
# ─────────────────────────────────────────────────────────────
resource "terraform_data" "actions_trigger" {
  for_each = var.config.actions
  input    = try(var.config.actions_sha256[each.key], null)
}

resource "terraform_data" "codespaces_trigger" {
  for_each = var.config.codespaces
  input    = try(var.config.codespaces_sha256[each.key], null)
}

resource "terraform_data" "dependabot_trigger" {
  for_each = var.config.dependabot
  input    = try(var.config.dependabot_sha256[each.key], null)
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
    replace_triggered_by = [terraform_data.actions_trigger[each.key]]
    ignore_changes       = [key_id, value_encrypted]
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
    replace_triggered_by = [terraform_data.codespaces_trigger[each.key]]
    ignore_changes       = [encrypted_value]
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
    replace_triggered_by = [terraform_data.dependabot_trigger[each.key]]
    ignore_changes       = [key_id, value_encrypted]
  }
}
