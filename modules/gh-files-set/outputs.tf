output "user_managed_files" {
  description = "Files marked as userManaged in the config (intended to be managed outside this module)"
  value       = [for f in var.config.files : "${f.file}/${f.branch}" if f.userManaged]
}
