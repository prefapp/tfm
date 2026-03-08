output "managed_files" {
  description = "All files managed by this module"
  value = [
    for f in var.config.files : {
      repository   = f.repository
      path         = f.file
      branch       = f.branch
      user_managed = f.userManaged
    }
  ]
}

output "user_managed_files" {
  description = "Files that will survive terraform destroy"
  value = [
    for f in var.config.files : "${f.repository}/${f.file}"
    if f.userManaged
  ]
}
