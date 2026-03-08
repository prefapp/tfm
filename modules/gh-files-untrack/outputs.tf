output "untracked_files" {
  description = "Files that were removed from state"
  value       = [for f in var.config.files : "${f.repository}/${f.file}"]
}
