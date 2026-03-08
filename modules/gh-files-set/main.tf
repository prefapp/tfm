# ─────────────────────────────────────────────────────────────
# Files where user wants to ignore changes (e.g. lifecycle_ignore_changes = ["content"])
# ─────────────────────────────────────────────────────────────
resource "github_repository_file" "with_ignore" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${f.branch}" => f
    if length(coalesce(f.lifecycle_ignore_changes, [])) > 0
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  lifecycle {
    ignore_changes = each.value.lifecycle_ignore_changes
  }
}

# ─────────────────────────────────────────────────────────────
# Files where Terraform should enforce the content (empty list)
# ─────────────────────────────────────────────────────────────
resource "github_repository_file" "without_ignore" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${f.branch}" => f
    if length(coalesce(f.lifecycle_ignore_changes, [])) == 0
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}
