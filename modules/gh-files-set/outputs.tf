output "user_managed_files" {
  description = "Files marked as userManaged (will survive destroy)"
  value       = [for f in var.config.files : "${f.repository}/${f.file}" if f.userManaged]
}
