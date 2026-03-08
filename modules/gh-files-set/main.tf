resource "github_repository_file" "files" {
  for_each = {
    for idx, f in var.config.files :
    "${f.repository}/${f.file}/${f.branch}" => f
  }

  repository          = each.value.repository
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = each.value.commitMessage
  overwrite_on_create = each.value.overwriteOnCreate

  # Optional lifecycle block (rarely used here, but kept for consistency)
  dynamic "lifecycle" {
    for_each = each.value.lifecycle != null && length(each.value.lifecycle) > 0 ? [each.value.lifecycle] : []
    content {
      # You can extend this later with ignore_changes, prevent_destroy, etc.
      # Currently empty placeholder
    }
  }
}
