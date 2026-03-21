# ─────────────────────────────────────────────────────────────
# Fetch repository info (validates existence + gives canonical name)
# ─────────────────────────────────────────────────────────────
data "github_repository" "this" {
  full_name = var.config.repository
}

# Normal files — Terraform fully enforces content
resource "github_repository_file" "managed" {
  for_each = {
    for f in var.config.files : "${f.file}/${f.branch}" => f
    if !f.userManaged
  }

  repository          = data.github_repository.this.name
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}

# User-managed files — provision once + ignore content drift
resource "github_repository_file" "user_managed" {
  for_each = {
    for f in var.config.files : "${f.file}/${f.branch}" => f
    if f.userManaged
  }

  repository          = data.github_repository.this.name
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  lifecycle {
    ignore_changes = [content]
  }
}
