output "managed_files" {
  description = "List of provisioned files and their lifecycle settings"
  value = [
    for f in var.config.files : {
      repository             = f.repository
      path                   = f.file
      branch                 = f.branch
      lifecycle_ignore_changes = f.lifecycle_ignore_changes
    }
  ]
}

output "files_with_ignore_content" {
  description = "Files where content changes are being ignored"
  value = [
    for f in var.config.files :
    "${f.repository}/${f.file}"
    if contains(f.lifecycle_ignore_changes, "content")
  ]
}
