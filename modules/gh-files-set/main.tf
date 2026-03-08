# Normal files — Terraform fully enforces content
resource "github_repository_file" "managed" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
    if !f.userManaged
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate
}

# User-managed files — provision once + ignore content changes
resource "github_repository_file" "user_managed" {
  for_each = {
    for f in var.config.files : "${f.repository}/${f.file}/${f.branch}" => f
    if f.userManaged
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  lifecycle {
    ignore_changes = [content]
  }
}
