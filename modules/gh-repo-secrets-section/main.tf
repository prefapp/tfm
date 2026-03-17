# ─────────────────────────────────────────────────────────────
# Gather repository data once per unique repo
# ─────────────────────────────────────────────────────────────
locals {
  # Collect every repository mentioned across all secret types
  all_repos = concat(
    [for v in var.config.actions : v.repository],
    [for v in var.config.codespaces : v.repository],
    [for v in var.config.dependabot : v.repository]
  )

  # Unique list so we only call the data source once per repo
  unique_repositories = toset(local.all_repos)
}

data "github_repository" "repos" {
  for_each = local.unique_repositories

  # Use `name` if your var.config.repository stores just the repo name (e.g. "my-repo")
  # (this is the most common case when the GitHub provider is configured with `owner = "your-org"`).
  # Use `full_name = each.key` instead if you store "org/repo" in the variable.
  name = each.key
}

# ─────────────────────────────────────────────────────────────
# GitHub Actions Secrets
# encrypted_value is ALREADY libsodium-encrypted against the repo public key
# Terraform does NOT perform any encryption
# ─────────────────────────────────────────────────────────────
resource "github_actions_secret" "this" {
  for_each = var.config.actions

  repository      = data.github_repository.repos[each.value.repository].name
  secret_name     = each.value.secretName
  encrypted_value = each.value.encryptedValue

  lifecycle {
    ignore_changes = [encrypted_value]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Codespaces Secrets
# encrypted_value is ALREADY libsodium-encrypted against the repo public key
# Terraform does NOT perform any encryption
# ─────────────────────────────────────────────────────────────
resource "github_codespaces_secret" "this" {
  for_each = var.config.codespaces

  repository      = data.github_repository.repos[each.value.repository].name
  secret_name     = each.value.secretName
  encrypted_value = each.value.encryptedValue

  lifecycle {
    ignore_changes = [encrypted_value]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Dependabot Secrets
# encrypted_value is ALREADY libsodium-encrypted against the repo public key
# Terraform does NOT perform any encryption
# ─────────────────────────────────────────────────────────────
resource "github_dependabot_secret" "this" {
  for_each = var.config.dependabot

  repository      = data.github_repository.repos[each.value.repository].name
  secret_name     = each.value.secretName
  encrypted_value = each.value.encryptedValue

  lifecycle {
    ignore_changes = [encrypted_value]
  }
}
