output "user_managed_files" {
  description = "Files that will survive terraform destroy"
  value       = [for f in var.config.files : "${f.repository}/${f.file}" if f.userManaged]
}
