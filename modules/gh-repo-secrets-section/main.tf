# ─────────────────────────────────────────────────────────────
# GitHub Actions Secrets
# encrypted_value is ALREADY libsodium-encrypted against the repo public key
# Terraform does NOT perform any encryption
# ─────────────────────────────────────────────────────────────
resource "github_actions_secret" "this" {
  for_each = var.config.actions

  repository      = each.value.repository
  secret_name     = each.value.secretName
  encrypted_value = each.value.encryptedValue

  lifecycle {
    ignore_changes = ["encrypted_value"]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Codespaces Secrets
# encrypted_value is ALREADY libsodium-encrypted against the repo public key
# Terraform does NOT perform any encryption
# ─────────────────────────────────────────────────────────────
resource "github_codespaces_secret" "this" {
  for_each = var.config.codespaces

  repository      = each.value.repository
  secret_name     = each.value.secretName
  encrypted_value = each.value.encryptedValue

  lifecycle {
    ignore_changes = ["encrypted_value"]
  }
}

# ─────────────────────────────────────────────────────────────
# GitHub Dependabot Secrets
# encrypted_value is ALREADY libsodium-encrypted against the repo public key
# Terraform does NOT perform any encryption
# ─────────────────────────────────────────────────────────────
resource "github_dependabot_secret" "this" {
  for_each = var.config.dependabot

  repository      = each.value.repository
  secret_name     = each.value.secretName
  encrypted_value = each.value.encryptedValue

  lifecycle {
    ignore_changes = ["encrypted_value"]
  }
}
