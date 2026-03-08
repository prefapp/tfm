# Files where ignoreContentChanges = true → Terraform ignores content changes
resource "github_repository_file" "ignore_content" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
    if f.ignoreContentChanges
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  lifecycle {
    ignore_changes = [content]   # ← NO QUOTES (required by OpenTofu)
  }
}

# Files where ignoreContentChanges = false → Terraform enforces the content
resource "github_repository_file" "enforce_content" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
    if !f.ignoreContentChanges
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}
