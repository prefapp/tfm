# ─────────────────────────────────────────────────────────────
# Fetch org public keys (conditionally, only when secrets exist)
# ─────────────────────────────────────────────────────────────
data "github_actions_organization_public_key" "this" {
  count = length(var.config.actions) > 0 ? 1 : 0
}

data "github_codespaces_organization_public_key" "this" {
  count = length(var.config.codespaces) > 0 ? 1 : 0
}

data "github_dependabot_organization_public_key" "this" {
  count = length(var.config.dependabot) > 0 ? 1 : 0
}

# ─────────────────────────────────────────────────────────────
# Resolve selected repository owner/repo strings to IDs
# ─────────────────────────────────────────────────────────────
locals {
  _actions_selected = flatten([
    for name, secret in var.config.actions : [
      for repo in secret.selected_repositories : { secret_name = name, repository = repo }
    ] if secret.visibility == "selected"
  ])

  _codespaces_selected = flatten([
    for name, secret in var.config.codespaces : [
      for repo in secret.selected_repositories : { secret_name = name, repository = repo }
    ] if secret.visibility == "selected"
  ])

  _dependabot_selected = flatten([
    for name, secret in var.config.dependabot : [
      for repo in secret.selected_repositories : { secret_name = name, repository = repo }
    ] if secret.visibility == "selected"
  ])

  all_selected_repositories = toset(concat(
    [for item in local._actions_selected : item.repository],
    [for item in local._codespaces_selected : item.repository],
    [for item in local._dependabot_selected : item.repository],
  ))
}

data "github_repository" "selected" {
  for_each  = local.all_selected_repositories
  full_name = each.value
}

# ─────────────────────────────────────────────────────────────
# Secret update triggers (deterministic SHA-256 of plaintext)
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
# GitHub Actions Organization Secrets
# ─────────────────────────────────────────────────────────────
resource "github_actions_organization_secret" "this" {
  for_each = var.config.actions

  secret_name     = each.key
  visibility      = each.value.visibility
  key_id          = one(data.github_actions_organization_public_key.this[*].key_id)
  value_encrypted = each.value.value

  lifecycle {
    replace_triggered_by = [terraform_data.actions_trigger[each.key]]
    ignore_changes       = [key_id, value_encrypted]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Actions Organization Secret Repositories (binding)
# ─────────────────────────────────────────────────────────────
resource "github_actions_organization_secret_repositories" "this" {
  for_each = {
    for name, secret in var.config.actions : name => secret
    if secret.visibility == "selected" && length(secret.selected_repositories) > 0
  }

  secret_name = each.key

  selected_repository_ids = [
    for repo in each.value.selected_repositories :
    data.github_repository.selected[repo].repo_id
  ]
}

# ─────────────────────────────────────────────────────────────
# GitHub Codespaces Organization Secrets
# ─────────────────────────────────────────────────────────────
resource "github_codespaces_organization_secret" "this" {
  for_each = var.config.codespaces

  secret_name     = each.key
  visibility      = each.value.visibility
  encrypted_value = each.value.value

  selected_repository_ids = each.value.visibility == "selected" ? [
    for repo in each.value.selected_repositories :
    data.github_repository.selected[repo].repo_id
  ] : null

  lifecycle {
    replace_triggered_by = [terraform_data.codespaces_trigger[each.key]]
    ignore_changes       = [encrypted_value]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Dependabot Organization Secrets
# ─────────────────────────────────────────────────────────────
resource "github_dependabot_organization_secret" "this" {
  for_each = var.config.dependabot

  secret_name     = each.key
  visibility      = each.value.visibility
  key_id          = one(data.github_dependabot_organization_public_key.this[*].key_id)
  value_encrypted = each.value.value

  lifecycle {
    replace_triggered_by = [terraform_data.dependabot_trigger[each.key]]
    ignore_changes       = [key_id, value_encrypted]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Dependabot Organization Secret Repositories (binding)
# ─────────────────────────────────────────────────────────────
resource "github_dependabot_organization_secret_repositories" "this" {
  for_each = {
    for name, secret in var.config.dependabot : name => secret
    if secret.visibility == "selected" && length(secret.selected_repositories) > 0
  }

  secret_name = each.key

  selected_repository_ids = [
    for repo in each.value.selected_repositories :
    data.github_repository.selected[repo].repo_id
  ]
}
