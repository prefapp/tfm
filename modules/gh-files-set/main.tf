resource "github_repository_file" "files" {
  for_each = {
    for f in var.config.files :
    "${f.repository}/${f.file}/${f.branch}" => f
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  # Lifecycle is now fully controlled from your config.json / YAML
  lifecycle {
    ignore_changes = each.value.lifecycle_ignore_changes
  }
}
