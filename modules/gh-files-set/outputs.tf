output "managed_files" {
  description = "List of all managed files"
  value = [
    for f in var.config.files : {
      repository           = f.repository
      path                 = f.file
      branch               = f.branch
      ignore_content_changes = f.ignoreContentChanges
    }
  ]
}

output "files_with_ignore_content" {
  description = "Files where content changes are ignored"
  value = [
    for f in var.config.files : "${f.repository}/${f.file}"
    if f.ignoreContentChanges
  ]
}
