output "installed_managed_files" {
  description = "Accumulated list of user-managed file addresses (\"<file>/<branch>\") that have been provisioned at least once. Grows monotonically as new userManaged files are applied; shrinks when a file transitions from userManaged = true to userManaged = false."
  value = tolist(setsubtract(
    toset(concat(
      var.installed_managed_files,
      [for f in var.config.files : "${f.file}/${f.branch}" if f.userManaged]
    )),
    toset([for f in var.config.files : "${f.file}/${f.branch}" if !f.userManaged])
  ))
}
