output "committed_files" {
  description = "List of files that were successfully managed"
  value = [
    for f in var.config.files :
    {
      repository = f.repository
      path       = f.file
      branch     = f.branch
    }
  ]
}

output "file_paths" {
  description = "Flat list of managed file paths (repo/path)"
  value = [
    for f in var.config.files : "${f.repository}/${f.file}"
  ]
}

output "commit_messages" {
  description = "Commit messages that were used"
  value       = [for f in var.config.files : f.commitMessage]
}
